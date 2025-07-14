// lib/helpers/currency_input_formatter.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/services/number_formatting_service.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormatType formatType;

  CurrencyInputFormatter({required this.formatType});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final separator = formatType == NumberFormatType.commaDecimal ? ',' : '.';
    String newText = newValue.text.replaceAll(RegExp('[^0-9$separator]'), '');

    // Ngăn người dùng nhập nhiều hơn một dấu phân cách
    if (newText.split(separator).length > 2) {
      return oldValue;
    }

    // Tách phần nguyên và phần thập phân
    List<String> parts = newText.split(separator);
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Định dạng phần nguyên
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart.replaceAll(RegExp(r'[,.]'), ''));
      if (number != null) {
        final formatter = NumberFormat(
            formatType == NumberFormatType.dotDecimal
                ? '#,##0'
                : '#,##0'.replaceAll(',', '.'),
            formatType == NumberFormatType.dotDecimal ? 'en_US' : 'vi_VN');
        integerPart = formatter.format(number);
      }
    }

    // Ghép lại chuỗi cuối cùng
    String finalText = integerPart;
    if (decimalPart != null) {
      finalText += separator + decimalPart;
    }

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}