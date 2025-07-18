// test/unit_conversion_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/services/unit_conversion_service.dart';
import 'package:mincloset/states/profile_page_state.dart';

void main() {
  // Khởi tạo đối tượng cần test
  final unitConversionService = UnitConversionService();

  // Nhóm các bài test cho UnitConversionService
  group('UnitConversionService Tests', () {

    // Test 1: Chuyển đổi từ C sang F
    test('Converts Celsius to Fahrenheit correctly', () {
      // Sắp xếp (Arrange): Dữ liệu đầu vào
      const celsius = 25.0;
      // Hành động (Act): Gọi hàm cần test
      final fahrenheit = unitConversionService.toFahrenheit(celsius);
      // Khẳng định (Assert): Kiểm tra kết quả
      expect(fahrenheit, 77.0);
    });

    // Test 2: Chuyển đổi từ cm sang feet và inches
    test('Converts cm to feet and inches correctly', () {
      // Arrange
      const cm = 175;
      // Act
      final result = unitConversionService.cmToFeetAndInches(cm);
      // Assert
      expect(result['feet'], 5);
      expect(result['inches'], 9);
    });

    // Test 3: Chuyển đổi từ feet và inches sang cm
    test('Converts feet and inches to cm correctly', () {
      // Arrange
      const feet = 5;
      const inches = 9;
      // Act
      final result = unitConversionService.feetAndInchesToCm(feet, inches);
      // Assert
      expect(result, 175);
    });

    // Test 4: Định dạng nhiệt độ
    test('Formats temperature correctly', () {
      expect(unitConversionService.formatTemperature(25, TempUnit.celsius), '25°C');
      expect(unitConversionService.formatTemperature(25, TempUnit.fahrenheit), '77°F');
    });
  });
}