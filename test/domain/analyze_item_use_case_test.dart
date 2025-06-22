// test/domain/analyze_item_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/services/classification_service.dart';
import 'package:mocktail/mocktail.dart';

// --- TẠO CÁC LỚP MOCK ---

// 1. Mock ClassificationService là phụ thuộc chính của use case
class MockClassificationService extends Mock implements ClassificationService {}

// 2. Vì XFile là một lớp từ package bên ngoài, chúng ta cần tạo một lớp Fake
//    để có thể đăng ký nó với mocktail.
class FakeXFile extends Fake implements XFile {
  @override
  final String path = 'fake/path/to/image.jpg';
}


void main() {
  late AnalyzeItemUseCase useCase;
  late MockClassificationService mockClassificationService;

  // Đăng ký lớp FakeXFile để mocktail có thể sử dụng `any()` hoặc `captureAny()`
  setUpAll(() {
    registerFallbackValue(FakeXFile());
  });

  setUp(() {
    mockClassificationService = MockClassificationService();
    useCase = AnalyzeItemUseCase(mockClassificationService);
  });

  group('AnalyzeItemUseCase', () {
    // Dữ liệu mẫu
    final tImageFile = FakeXFile();
    final tAnalysisResult = {
      'name': 'Áo thun trắng',
      'category': 'Áo > Áo thun',
      'colors': ['Trắng'],
    };

    test('Nên gọi classifyImage trên service và trả về kết quả', () async {
      // Sắp xếp (Arrange)
      // Giả lập rằng khi service được gọi với bất kỳ file ảnh nào (`any()`),
      // nó sẽ trả về kết quả mẫu của chúng ta.
      when(() => mockClassificationService.classifyImage(any()))
          .thenAnswer((_) async => tAnalysisResult);

      // Hành động (Act)
      // Thực thi use case với file ảnh giả
      final result = await useCase.execute(tImageFile);

      // Kiểm chứng (Assert)
      // 1. Kiểm tra xem kết quả trả về từ use case có đúng là kết quả chúng ta đã giả lập không.
      expect(result, tAnalysisResult);

      // 2. Xác minh rằng phương thức `classifyImage` của service đã được gọi
      //    đúng 1 lần với chính xác đối tượng tImageFile.
      verify(() => mockClassificationService.classifyImage(tImageFile)).called(1);
    });
  });
}