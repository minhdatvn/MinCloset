// lib/services/weather_image_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class WeatherImageService {
  final _random = Random();
  List<String> _weatherImagePaths = [];

  Future<void> init() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    _weatherImagePaths = manifestMap.keys
        .where((String key) => key.contains('assets/images/weather_backgrounds/'))
        .toList();
  }

  void precacheWeatherImages(BuildContext context) {
    for (final path in _weatherImagePaths) {
      precacheImage(AssetImage(path), context);
    }
  }

  // <<< BẮT ĐẦU THAY ĐỔI TẠI ĐÂY >>>
  String getBackgroundImageForWeather(String? iconCode, {String? currentPath}) {
    const String defaultImage = 'assets/images/weather_backgrounds/default_1.webp';
    final String representativeCode = _mapIconToCode(iconCode);

    // 1. Lấy danh sách tất cả các ảnh phù hợp
    final matchingImages = _weatherImagePaths
        .where((path) => path.contains('/$representativeCode'))
        .toList();

    if (matchingImages.isEmpty) {
      return defaultImage;
    }
    
    // Nếu chỉ có một ảnh, trả về chính ảnh đó
    if (matchingImages.length == 1) {
      return matchingImages.first;
    }

    // 2. Tạo một danh sách mới, loại bỏ ảnh hiện tại
    final eligibleImages = matchingImages.where((path) => path != currentPath).toList();

    // 3. Chọn ngẫu nhiên từ danh sách đã được lọc
    // Nếu sau khi lọc không còn ảnh nào (trường hợp hiếm), thì vẫn chọn từ danh sách gốc
    if (eligibleImages.isEmpty) {
      return matchingImages[_random.nextInt(matchingImages.length)];
    }
    
    return eligibleImages[_random.nextInt(eligibleImages.length)];
  }
  // <<< KẾT THÚC THAY ĐỔI >>>

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