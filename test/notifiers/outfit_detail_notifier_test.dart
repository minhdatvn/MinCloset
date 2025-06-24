// test/notifiers/outfit_detail_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/image_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';

// TẠO CÁC LỚP MOCK
class MockOutfitRepository extends Mock implements OutfitRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockImageHelper extends Mock implements ImageHelper {}

class FakeOutfit extends Fake implements Outfit {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOutfit());
  });

  late ProviderContainer container;
  late MockOutfitRepository mockOutfitRepository;
  late MockClothingItemRepository mockClothingItemRepository;
  late MockImageHelper mockImageHelper;

  const initialOutfit = Outfit(
    id: 'outfit1',
    name: 'Đi Đà Lạt',
    imagePath: 'path/1.png',
    thumbnailPath: 'thumb/1.png',
    itemIds: 'itemA,itemB',
    isFixed: false,
  );

  setUp(() {
    mockOutfitRepository = MockOutfitRepository();
    mockClothingItemRepository = MockClothingItemRepository();
    mockImageHelper = MockImageHelper();
    
    container = ProviderContainer(
      overrides: [
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepository),
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepository),
        imageHelperProvider.overrideWithValue(mockImageHelper),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });
  
  group('OutfitDetailNotifier', () {
    test('updateName - nên gọi updateOutfit trong repository và cập nhật state', () async {
      const newName = 'Đi Vũng Tàu';
      when(() => mockOutfitRepository.updateOutfit(any())).thenAnswer((_) async {});
      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);
      await notifier.updateName(newName);
      expect(container.read(outfitDetailProvider(initialOutfit)).name, newName);
      final captured = verify(() => mockOutfitRepository.updateOutfit(captureAny())).captured;
      expect((captured.first as Outfit).name, newName);
    });

    test('toggleIsFixed - nên thành công khi không có xung đột', () async {
      when(() => mockOutfitRepository.getFixedOutfits()).thenAnswer((_) async => []);
      when(() => mockOutfitRepository.updateOutfit(any())).thenAnswer((_) async {});
      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);
      final result = await notifier.toggleIsFixed(true);
      expect(result, isNull);
      expect(container.read(outfitDetailProvider(initialOutfit)).isFixed, isTrue);
      verify(() => mockOutfitRepository.updateOutfit(any())).called(1);
    });

    test('toggleIsFixed - nên trả về lỗi khi vật phẩm đã thuộc bộ đồ cố định khác', () async {
      final conflictingOutfit = const Outfit(id: 'outfit2', name: 'Đồng phục công ty', imagePath: 'path/2.png', itemIds: 'itemB,itemC', isFixed: true);
      when(() => mockOutfitRepository.getFixedOutfits()).thenAnswer((_) async => [conflictingOutfit]);
      const conflictingItem = ClothingItem(id: 'itemB', name: 'Áo sơ mi trắng', category: 'Áo', color: 'Trắng', imagePath: 'path/b', closetId: 'c1');
      when(() => mockClothingItemRepository.getItemById('itemB')).thenAnswer((_) async => conflictingItem);
      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);
      final result = await notifier.toggleIsFixed(true);
      
      // <<< SỬA LẠI CHUỖI MONG ĐỢI Ở ĐÂY >>>
      expect(result, isNotNull);
      expect(result, contains("'Áo sơ mi trắng' already belongs to another fixed outfit"));
      
      expect(container.read(outfitDetailProvider(initialOutfit)).isFixed, isFalse);
      verifyNever(() => mockOutfitRepository.updateOutfit(any()));
    });

    test('deleteOutfit - nên gọi deleteImage và deleteOutfit trong repository', () async {
      when(() => mockOutfitRepository.deleteOutfit(any())).thenAnswer((_) async {});
      when(() => mockImageHelper.deleteImageAndThumbnail(imagePath: any(named: 'imagePath'), thumbnailPath: any(named: 'thumbnailPath')))
          .thenAnswer((_) async {});
      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);
      await notifier.deleteOutfit();
      verify(() => mockImageHelper.deleteImageAndThumbnail(
        imagePath: initialOutfit.imagePath,
        thumbnailPath: initialOutfit.thumbnailPath
      )).called(1);
      verify(() => mockOutfitRepository.deleteOutfit(initialOutfit.id)).called(1);
    });
  });
}