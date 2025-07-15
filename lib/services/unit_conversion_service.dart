// lib/services/unit_conversion_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/states/profile_page_state.dart';

class UnitConversionService {
  // --- Temperature --- (Không thay đổi)
  double toFahrenheit(double celsius) => (celsius * 9 / 5) + 32;
  double toCelsius(double fahrenheit) => (fahrenheit - 32) * 5 / 9;

  String formatTemperature(double tempCelsius, TempUnit unit) {
    final temp = (unit == TempUnit.celsius) ? tempCelsius : toFahrenheit(tempCelsius);
    return '${temp.toStringAsFixed(0)}°${unit == TempUnit.celsius ? 'C' : 'F'}';
  }

  // --- Height ---
  // 1 inch = 2.54 cm
  // 1 foot = 12 inches

  // <<< HÀM MỚI 1: Chuyển cm sang một cặp {feet, inches} >>>
  Map<String, int> cmToFeetAndInches(int cm) {
    if (cm <= 0) return {'feet': 0, 'inches': 0};
    int totalInches = (cm / 2.54).round();
    int feet = totalInches ~/ 12;
    int inches = totalInches % 12;
    return {'feet': feet, 'inches': inches};
  }

  // <<< HÀM MỚI 2: Chuyển cặp {feet, inches} về lại cm >>>
  int feetAndInchesToCm(int feet, int inches) {
    int totalInches = (feet * 12) + inches;
    return (totalInches * 2.54).round();
  }
  
  // Hàm formatHeight cũ không còn cần thiết, nhưng chúng ta có thể giữ lại để tham khảo
  // hoặc xóa đi để mã nguồn gọn hơn.

  // --- Weight --- (Không thay đổi)
  int kgToLbs(int kg) => (kg * 2.20462).round();
  int lbsToKg(int lbs) => (lbs / 2.20462).round();

  String formatWeight(int? weightKg, WeightUnit unit) {
    if (weightKg == null) return 'N/A';
    if (unit == WeightUnit.kg) {
      return '$weightKg kg';
    } else {
      return '${kgToLbs(weightKg)} lbs';
    }
  }
}

final unitConversionServiceProvider = Provider<UnitConversionService>((ref) {
  return UnitConversionService();
});