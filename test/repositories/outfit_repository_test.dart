// test/repositories/outfit_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class FakeOutfit extends Fake implements Outfit {}

void main() {
  late OutfitRepository repository;
  late MockDatabaseHelper mockDbHelper;

  setUpAll(() {
    registerFallbackValue(FakeOutfit());
  });

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    repository = OutfitRepository(mockDbHelper);
  });

  final tOutfitId = const Uuid().v4();
  final tOutfit = Outfit(
    id: tOutfitId,
    name: 'Đi chơi cuối tuần',
    imagePath: 'path/to/image.png',
    thumbnailPath: 'path/to/thumb.png',
    itemIds: 'id1,id2,id3',
    isFixed: false,
  );

  final tOutfitMap = {
    'id': tOutfit.id,
    'name': tOutfit.name,
    'imagePath': tOutfit.imagePath,
    'thumbnailPath': tOutfit.thumbnailPath,
    'itemIds': tOutfit.itemIds,
    'is_fixed': 0
  };

  group('OutfitRepository', () {

    test('getOutfits - nên gọi dbHelper với đúng limit/offset và trả về List<Outfit>', () async {
      when(() => mockDbHelper.getOutfits(limit: 10, offset: 0)).thenAnswer((_) async => [tOutfitMap]);
      final result = await repository.getOutfits(limit: 10, offset: 0);
      expect(result, isA<List<Outfit>>());
      expect(result.length, 1);
      expect(result.first, tOutfit); 
      verify(() => mockDbHelper.getOutfits(limit: 10, offset: 0)).called(1);
    });

    test('getOutfits - nên trả về một danh sách rỗng khi CSDL không có dữ liệu', () async {
      when(() => mockDbHelper.getOutfits(limit: any(named: 'limit'), offset: any(named: 'offset'))).thenAnswer((_) async => []);
      final result = await repository.getOutfits();
      expect(result, isA<List<Outfit>>());
      expect(result.isEmpty, isTrue);
      verify(() => mockDbHelper.getOutfits(limit: null, offset: null)).called(1);
    });
    
    // <<< SỬA LỖI NẰM Ở BÀI TEST NÀY >>>
    test('insertOutfit - nên gọi insertOutfit trên dbHelper với đúng đối tượng Outfit', () async {
      // Arrange
      when(() => mockDbHelper.insertOutfit(any())).thenAnswer((_) async {});

      // Act
      await repository.insertOutfit(tOutfit);

      // Assert
      final captured = verify(() => mockDbHelper.insertOutfit(captureAny())).captured;
      // Bây giờ chúng ta mong muốn đối số bị bắt giữ phải chính là đối tượng `tOutfit`
      expect(captured.first, tOutfit);
    });

    test('deleteOutfit - nên gọi deleteOutfit trên dbHelper với ID chính xác', () async {
      when(() => mockDbHelper.deleteOutfit(any())).thenAnswer((_) async {});
      await repository.deleteOutfit(tOutfitId);
      verify(() => mockDbHelper.deleteOutfit(tOutfitId)).called(1);
    });
    
    test('getFixedOutfits - nên trả về danh sách các outfit có is_fixed = 1', () async {
      final tFixedOutfit = tOutfit.copyWith(isFixed: true);
      final tFixedOutfitMap = Map<String, dynamic>.from(tOutfit.toMap())
        ..['is_fixed'] = 1;
      
      when(() => mockDbHelper.getFixedOutfits()).thenAnswer((_) async => [tFixedOutfitMap]);
      final result = await repository.getFixedOutfits();
      expect(result.length, 1);
      expect(result.first, tFixedOutfit);
      verify(() => mockDbHelper.getFixedOutfits()).called(1);
    });
  });
}