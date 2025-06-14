// file: lib/utils/logger.dart
import 'package:logger/logger.dart';

// Khởi tạo một logger với định dạng đẹp mắt (PrettyPrinter)
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // số lượng hàm trong stack trace được hiển thị
    errorMethodCount: 5, // số lượng hàm trong stack trace khi có lỗi
    lineLength: 120, // chiều dài dòng
    colors: true, // bật màu sắc
    printEmojis: true, // in emoji cho mỗi cấp độ log
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // in thời gian
  ),
);