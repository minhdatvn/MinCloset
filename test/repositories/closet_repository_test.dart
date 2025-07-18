// test/repositories/closet_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

// Hàm đặc biệt để khởi tạo môi trường sqflite cho desktop test
void sqfliteTestInit() {
  // Khởi tạo sqflite FFI
  sqfliteFfiInit();
  // Thay thế database factory mặc định bằng factory của FFI
  databaseFactory = databaseFactoryFfi;
}

void main() {
  // Gọi hàm khởi tạo ngay từ đầu
  sqfliteTestInit();

  late DatabaseHelper databaseHelper;
  late ClosetRepository closetRepository;

  // setUp sẽ được gọi trước mỗi bài test
  setUp(() async {
    // Sử dụng một tên CSDL đặc biệt và chỉ tồn tại trong bộ nhớ
    // In-memory database sẽ tự động bị xóa khi test kết thúc
    databaseHelper = DatabaseHelper.instance;
    await databaseHelper.database; // Đảm bảo CSDL đã được tạo
    closetRepository = ClosetRepository(databaseHelper);
  });
  
  // tearDown sẽ được gọi sau mỗi bài test để dọn dẹp
  tearDown(() async {
    // Mặc dù là in-memory, chúng ta vẫn nên đóng kết nối
    await databaseHelper.close();
  });

  group('ClosetRepository Tests', () {
    test('Nên thêm một closet mới vào CSDL và lấy ra thành công', () async {
      // ARRANGE: Tạo một đối tượng Closet để thêm vào CSDL
      final newCloset = Closet(
        id: const Uuid().v4(),
        name: 'Đồ đi biển',
        iconName: 'Travel',
        colorHex: '#BBDEFB',
      );

      // ACT 1: Gọi hàm insertCloset của repository
      final insertResult = await closetRepository.insertCloset(newCloset);

      // ASSERT 1: Kiểm tra xem việc insert có trả về thành công không (Right)
      expect(insertResult.isRight(), isTrue);

      // ACT 2: Gọi hàm getClosets để lấy tất cả dữ liệu
      final closetsResult = await closetRepository.getClosets();

      // ASSERT 2:
      // - Kiểm tra việc lấy dữ liệu có thành công không
      expect(closetsResult.isRight(), isTrue);
      
      // - Lấy ra danh sách các closets từ kết quả
      final closetsList = closetsResult.getOrElse((_) => []);
      
      // - Kiểm tra xem danh sách có chứa closet chúng ta vừa thêm vào không
      expect(closetsList, contains(newCloset));
    });
  });
}