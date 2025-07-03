// lib/helpers/currency_input_formatter.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/services/number_formatting_service.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormatType formatType;

  CurrencyInputFormatter({required this.formatType});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // 1. Lấy chuỗi chỉ chứa số từ giá trị người dùng nhập
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    
    // 2. Chuyển chuỗi số thành kiểu double
    double value = double.parse(newText);

    // 3. Sử dụng NumberFormat để định dạng số
    final locale = formatType == NumberFormatType.commaDecimal ? 'en_US' : 'vi_VN';
    final formatter = NumberFormat.decimalPattern(locale);
    String formattedText = formatter.format(value);

    // 4. Tính toán vị trí con trỏ mới để giữ nó ở đúng vị trí tương đối
    // so với các ký tự số, tránh việc con trỏ nhảy về cuối.
    int newCursorOffset = newValue.selection.baseOffset +
        (formattedText.length - newValue.text.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newCursorOffset,
      ),
    );
  }
}