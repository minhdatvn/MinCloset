// lib/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Đặt tên các key ở một nơi để dễ quản lý
abstract class SecureStorageKeys {
  static const geminiApiKey = 'GEMINI_API_KEY';
  static const openWeatherApiKey = 'OPENWEATHER_API_KEY';
  static const sentryDsn = 'SENTRY_DSN';  
}

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Hàm để ghi một key
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Hàm để đọc một key
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Hàm để xóa một key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}