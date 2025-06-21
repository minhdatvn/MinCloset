// test/notifiers/add_item_notifier_test.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
// <<< SỬA LỖI TẠI ĐÂY: Sửa 'packagee' thành 'package' >>>
import 'package:mocktail/mocktail.dart';

// 1. Tạo các lớp Mock cho tất cả các phụ thuộc
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockValidateItemNameUseCase extends Mock implements ValidateItemNameUseCase {}
class MockValidateRequiredFieldsUseCase extends Mock implements ValidateRequiredFieldsUseCase {}
class MockAnalyzeItemUseCase extends Mock implements AnalyzeItemUseCase {}
class FakeClothingItem extends Fake implements ClothingItem {}

void main() {
  // Đăng ký fallback value cho các đối số tùy chỉnh
  setUpAll(() {
    registerFallbackValue(FakeClothingItem());
    registerFallbackValue(const AddItemState());
  });

  // Khai báo các biến và ProviderContainer
  late ProviderContainer container;
  late MockClothingItemRepository mockClothingItemRepository;
  late MockValidateItemNameUseCase mockValidateItemNameUseCase;
  late MockValidateRequiredFieldsUseCase mockValidateRequiredFieldsUseCase;
  late MockAnalyzeItemUseCase mockAnalyzeItemUseCase;

  // Dữ liệu mẫu
  final tArgs = ItemNotifierArgs(tempId: 'temp1', newImage: null);

  // 2. Dùng `setUp` để tạo một ProviderContainer mới cho mỗi bài test
  // Điều này đảm bảo các bài test không ảnh hưởng đến nhau
  setUp(() {
    mockClothingItemRepository = MockClothingItemRepository();
    mockValidateItemNameUseCase = MockValidateItemNameUseCase();
    mockValidateRequiredFieldsUseCase = MockValidateRequiredFieldsUseCase();
    mockAnalyzeItemUseCase = MockAnalyzeItemUseCase();

    // Tạo container và ghi đè các provider bằng các lớp mock
    container = ProviderContainer(
      overrides: [
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepository),
        validateItemNameUseCaseProvider.overrideWithValue(mockValidateItemNameUseCase),
        validateRequiredFieldsUseCaseProvider.overrideWithValue(mockValidateRequiredFieldsUseCase),
        analyzeItemUseCaseProvider.overrideWithValue(mockAnalyzeItemUseCase),
      ],
    );
  });

  // Dọn dẹp container sau mỗi bài test
  tearDown(() {
    container.dispose();
  });

  group('AddItemNotifier Tests', () {
    test('Trạng thái ban đầu nên là AddItemState rỗng', () {
      // Act: đọc trạng thái của provider ngay sau khi khởi tạo
      final state = container.read(addItemProvider(tArgs));
      // Assert
      expect(state, equals(AddItemState(id: 'temp1', image: null)));
    });

    test('onNameChanged nên cập nhật tên trong state', () {
      // Arrange: lấy ra notifier
      final notifier = container.read(addItemProvider(tArgs).notifier);

      // Act: gọi hàm cần test
      notifier.onNameChanged('Áo mới');

      // Assert: kiểm tra xem state đã được cập nhật đúng chưa
      expect(container.read(addItemProvider(tArgs)).name, 'Áo mới');
    });

    group('saveItem', () {
      test('Nên trả về true và gọi repository khi validation thành công', () async {
        // Arrange
        // Giả lập rằng tất cả các bước validation đều trả về thành công
        when(() => mockValidateRequiredFieldsUseCase.executeForSingle(any()))
            .thenReturn(ValidationResult.success());
        when(() => mockValidateItemNameUseCase.forSingleItem(name: any(named: 'name'), existingId: any(named: 'existingId')))
            .thenAnswer((_) async => ValidationResult.success());
        // Giả lập hàm insert của repo không làm gì cả
        when(() => mockClothingItemRepository.insertItem(any())).thenAnswer((_) async {});

        final notifier = container.read(addItemProvider(tArgs).notifier);
        // Điền các trường bắt buộc
        notifier.onNameChanged('Tên hợp lệ');
        notifier.onClosetChanged('closet1');
        notifier.onCategoryChanged('Áo > Áo thun');
        // Giả lập đã có ảnh
        container.read(addItemProvider(tArgs).notifier).state = container.read(addItemProvider(tArgs)).copyWith(image: File('dummy.path'));


        // Act
        final result = await notifier.saveItem();

        // Assert
        expect(result, isTrue);
        // Xác minh rằng `insertItem` đã được gọi đúng 1 lần
        verify(() => mockClothingItemRepository.insertItem(any())).called(1);
        // Đảm bảo không có lỗi nào được ghi nhận trong state
        expect(container.read(addItemProvider(tArgs)).errorMessage, isNull);
      });

      test('Nên trả về false và đặt errorMessage khi validation trường bắt buộc thất bại', () async {
        // Arrange
        // Giả lập rằng validation trường bắt buộc thất bại
        when(() => mockValidateRequiredFieldsUseCase.executeForSingle(any()))
            .thenReturn(ValidationResult.failure('Vui lòng nhập tên'));

        final notifier = container.read(addItemProvider(tArgs).notifier);
        container.read(addItemProvider(tArgs).notifier).state = container.read(addItemProvider(tArgs)).copyWith(image: File('dummy.path'));

        // Act
        final result = await notifier.saveItem();

        // Assert
        expect(result, isFalse);
        // Xác minh rằng repo không bao giờ được gọi đến
        verifyNever(() => mockClothingItemRepository.insertItem(any()));
        // Kiểm tra state có chứa thông báo lỗi chính xác
        expect(container.read(addItemProvider(tArgs)).errorMessage, 'Vui lòng nhập tên');
      });
    });
  });
}