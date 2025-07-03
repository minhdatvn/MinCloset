// lib/services/number_formatting_service.dart
import 'package:intl/intl.dart';

// Định nghĩa các kiểu định dạng số để dễ quản lý
enum NumberFormatType {
  commaDecimal, // 10,000.50
  dotDecimal,   // 10.000,50
}

class NumberFormattingService {
  String formatPrice({
    required double price,
    String? currency, // 'VND', 'USD', etc.
    NumberFormatType formatType = NumberFormatType.commaDecimal,
  }) {
    // Chọn locale dựa trên định dạng mong muốn
    // 'en_US' dùng cho định dạng 10,000.00
    // 'vi_VN' dùng cho định dạng 10.000,00
    final locale = formatType == NumberFormatType.commaDecimal ? 'en_US' : 'vi_VN';

    // Tạo một đối tượng NumberFormat
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: _getCurrencySymbol(currency), // Lấy ký hiệu tiền tệ
      decimalDigits: 0, // Không hiển thị số thập phân cho giá trị lớn
    );

    return formatter.format(price);
  }

  String _getCurrencySymbol(String? currencyCode) {
    switch (currencyCode) {
      case 'VND':
        return '₫';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return ''; // Không có ký hiệu nếu không xác định
    }
  }
}