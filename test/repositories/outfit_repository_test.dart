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
    itemIds: 'id1,id2,id3',
    isFixed: false,
  );

  group('OutfitRepository', () {

    test('getOutfits - nên trả về một danh sách Outfit khi CSDL có dữ liệu', () async {
      // Arrange
      when(() => mockDbHelper.getOutfits()).thenAnswer((_) async => [tOutfit]);

      // Act
      final result = await repository.getOutfits();

      // Assert
      expect(result, isA<List<Outfit>>());
      expect(result.length, 1);
      expect(result.first, tOutfit);
      verify(() => mockDbHelper.getOutfits()).called(1);
    });

    test('getOutfits - nên trả về một danh sách rỗng khi CSDL không có dữ liệu', () async {
      // Arrange
      when(() => mockDbHelper.getOutfits()).thenAnswer((_) async => []);

      // Act
      final result = await repository.getOutfits();

      // Assert
      expect(result, isA<List<Outfit>>());
      expect(result.isEmpty, isTrue);
      verify(() => mockDbHelper.getOutfits()).called(1);
    });
    
    test('insertOutfit - nên gọi insertOutfit trên dbHelper với dữ liệu chính xác', () async {
      // Arrange
      when(() => mockDbHelper.insertOutfit(any())).thenAnswer((_) async {});

      // Act
      await repository.insertOutfit(tOutfit);

      // Assert
      final captured = verify(() => mockDbHelper.insertOutfit(captureAny())).captured;
      // <<< DÒNG ĐÃ ĐƯỢC SỬA LỖI >>>
      // So sánh đối tượng Outfit bị bắt giữ với đối tượng Outfit gốc.
      expect(captured.first, tOutfit);
    });

    test('deleteOutfit - nên gọi deleteOutfit trên dbHelper với ID chính xác', () async {
      // Arrange
      when(() => mockDbHelper.deleteOutfit(any())).thenAnswer((_) async {});

      // Act
      await repository.deleteOutfit(tOutfitId);

      // Assert
      verify(() => mockDbHelper.deleteOutfit(tOutfitId)).called(1);
    });
    
    test('getFixedOutfits - nên trả về danh sách các outfit có is_fixed = 1', () async {
      // Arrange
      final tFixedOutfit = tOutfit.copyWith(isFixed: true);
      final tFixedOutfitMap = Map<String, dynamic>.from(tOutfit.toMap())
        ..['is_fixed'] = 1;
      
      when(() => mockDbHelper.getFixedOutfits()).thenAnswer((_) async => [tFixedOutfitMap]);

      // Act
      final result = await repository.getFixedOutfits();

      // Assert
      expect(result.length, 1);
      expect(result.first, tFixedOutfit);
      verify(() => mockDbHelper.getFixedOutfits()).called(1);
    });
  });
}