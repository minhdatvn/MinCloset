// test/notifiers/batch_add_item_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mocktail/mocktail.dart';

// TẠO CÁC LỚP MOCK
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockAnalyzeItemUseCase extends Mock implements AnalyzeItemUseCase {}
class MockValidateRequiredFieldsUseCase extends Mock implements ValidateRequiredFieldsUseCase {}
class MockValidateItemNameUseCase extends Mock implements ValidateItemNameUseCase {}
class FakeAddItemState extends Fake implements AddItemState {}

class FakeXFile extends Fake implements XFile {
  final String fakePath;
  FakeXFile(this.fakePath);

  @override
  String get path => fakePath;
}

void main() {
  // ĐĂNG KÝ FALLBACK VALUE
  setUpAll(() {
    // <<< SỬA LỖI Ở ĐÂY: Thêm dòng đăng ký fallback value cho XFile >>>
    registerFallbackValue(FakeXFile(''));

    registerFallbackValue(FakeAddItemState());
    registerFallbackValue(<AddItemState>[]);
  });

  // KHAI BÁO BIẾN
  late ProviderContainer container;
  late MockClothingItemRepository mockClothingItemRepo;
  late MockAnalyzeItemUseCase mockAnalyzeItemUseCase;
  late MockValidateRequiredFieldsUseCase mockValidateRequiredFieldsUseCase;
  late MockValidateItemNameUseCase mockValidateItemNameUseCase;

  // Dữ liệu giả
  final fakeImage1 = FakeXFile('path/to/fake1.jpg');
  final fakeImage2 = FakeXFile('path/to/fake2.jpg');
  final analysisResult1 = {'name': 'Áo 1', 'category': 'Áo > Áo thun', 'colors': ['Trắng']};
  final analysisResult2 = {'name': 'Quần 1', 'category': 'Quần > Quần jeans', 'colors': ['Xanh']};


  // HÀM `setUp`
  setUp(() {
    mockClothingItemRepo = MockClothingItemRepository();
    mockAnalyzeItemUseCase = MockAnalyzeItemUseCase();
    mockValidateRequiredFieldsUseCase = MockValidateRequiredFieldsUseCase();
    mockValidateItemNameUseCase = MockValidateItemNameUseCase();

    container = ProviderContainer(
      overrides: [
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepo),
        analyzeItemUseCaseProvider.overrideWithValue(mockAnalyzeItemUseCase),
        validateRequiredFieldsUseCaseProvider.overrideWithValue(mockValidateRequiredFieldsUseCase),
        validateItemNameUseCaseProvider.overrideWithValue(mockValidateItemNameUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BatchAddItemNotifier', () {
    test('analyzeAllImages nên tạo ra danh sách itemArgsList khi thành công', () async {
      // Arrange
      when(() => mockAnalyzeItemUseCase.execute(fakeImage1)).thenAnswer((_) async => analysisResult1);
      when(() => mockAnalyzeItemUseCase.execute(fakeImage2)).thenAnswer((_) async => analysisResult2);

      final notifier = container.read(batchAddItemProvider.notifier);

      // Act
      await notifier.analyzeAllImages([fakeImage1, fakeImage2]);

      // Assert
      final state = container.read(batchAddItemProvider);
      expect(state.isLoading, isFalse);
      expect(state.analysisSuccess, isTrue);
      expect(state.itemArgsList.length, 2);
      expect(state.itemArgsList[0].preAnalyzedState?.name, 'Áo 1');
      expect(state.itemArgsList[1].preAnalyzedState?.name, 'Quần 1');
    });

    test('saveAll nên báo lỗi nếu validation thất bại', () async {
      // Arrange
      when(() => mockAnalyzeItemUseCase.execute(any())).thenAnswer((_) async => analysisResult1);
      final notifier = container.read(batchAddItemProvider.notifier);
      await notifier.analyzeAllImages([fakeImage1]);

      when(() => mockValidateRequiredFieldsUseCase.executeForBatch(any()))
          .thenReturn(ValidationResult.failure('Vui lòng nhập tên cho Món đồ số 1', errorIndex: 0));
      
      when(() => mockClothingItemRepo.insertBatchItems(any())).thenAnswer((_) async {});

      // Act
      await notifier.saveAll();

      // Assert
      final state = container.read(batchAddItemProvider);
      expect(state.isSaving, isFalse);
      expect(state.saveSuccess, isFalse);
      expect(state.saveErrorMessage, 'Vui lòng nhập tên cho Món đồ số 1');

      verifyNever(() => mockClothingItemRepo.insertBatchItems(any()));
    });
    
    test('saveAll nên gọi insertBatchItems khi validation thành công', () async {
      // Arrange
      when(() => mockAnalyzeItemUseCase.execute(any())).thenAnswer((_) async => analysisResult1);
      final notifier = container.read(batchAddItemProvider.notifier);
      await notifier.analyzeAllImages([fakeImage1]);

      final itemArgs = container.read(batchAddItemProvider).itemArgsList[0];
      container.read(addItemProvider(itemArgs).notifier).onClosetChanged('closet1');

      when(() => mockValidateRequiredFieldsUseCase.executeForBatch(any())).thenReturn(ValidationResult.success());
      when(() => mockValidateItemNameUseCase.forBatch(any())).thenAnswer((_) async => ValidationResult.success());

      when(() => mockClothingItemRepo.insertBatchItems(any())).thenAnswer((_) async {});

      // Act
      await notifier.saveAll();

      // Assert
      final state = container.read(batchAddItemProvider);
      expect(state.isSaving, isFalse);
      expect(state.saveSuccess, isTrue);
      expect(state.saveErrorMessage, isNull);

      verify(() => mockClothingItemRepo.insertBatchItems(any())).called(1);
    });
  });
}