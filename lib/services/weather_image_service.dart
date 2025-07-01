// lib/services/weather_image_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class WeatherImageService {
  final _random = Random();
  List<String> _weatherImagePaths = [];

  // Hàm init sẽ được gọi một lần duy nhất để tải và xử lý danh sách assets
  Future<void> init() async {
    // 1. Tải nội dung của file AssetManifest.json
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // 2. Lọc ra tất cả các đường dẫn ảnh thuộc thư mục weather_backgrounds
    _weatherImagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/images/weather_backgrounds/'))
        .toList();
  }

  // Hàm này sẽ thay thế cho hàm cũ trong WeatherHelper
  String getBackgroundImageForWeather(String? iconCode) {
    const String defaultImage = 'assets/images/weather_backgrounds/default_1.webp';
    final String representativeCode = _mapIconToCode(iconCode);

    // Tìm tất cả các ảnh phù hợp với mã thời tiết
    final matchingImages = _weatherImagePaths
        .where((path) => path.contains('/$representativeCode'))
        .toList();

    // Nếu không có ảnh nào phù hợp, trả về ảnh mặc định
    if (matchingImages.isEmpty) {
      return defaultImage;
    }

    // Chọn ngẫu nhiên một ảnh từ danh sách phù hợp
    return matchingImages[_random.nextInt(matchingImages.length)];
  }

  // Hàm map này vẫn giữ nguyên như cũ
  String _mapIconToCode(String? iconCode) {
    if (iconCode == null) return 'default';
    switch (iconCode) {
      case '01d': case '01n': return '01d';
      case '02d': case '02n': case '03d': case '03n': case '04d': case '04n': return '04d';
      case '09d': case '09n': case '10d': case '10n': return '10d';
      case '11d': case '11n': return '11d';
      case '13d': case '13n': return '13d';
      case '50d': case '50n': return '50d';
      default: return 'default';
    }
  }
}