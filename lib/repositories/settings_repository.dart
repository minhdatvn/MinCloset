// lib/repositories/settings_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';

/// Repository để quản lý việc truy cập dữ liệu cài đặt người dùng.
class SettingsRepository {
  final Ref _ref;

  SettingsRepository(this._ref);

  static const _userNameKey = 'user_name';
  static const _avatarPathKey = 'user_avatar_path';
  static const _genderKey = 'user_gender';
  static const _dobKey = 'user_dob';
  static const _cityKey = 'user_city';
  static const _styleKey = 'user_style';
  static const _currencyKey = 'user_currency';
  static const _numberFormatKey = 'user_number_format';

  /// Lấy toàn bộ thông tin profile của người dùng
  Future<Map<String, dynamic>> getUserProfile() async {
    // SỬA LỖI: Lấy instance của SharedPreferences ở đầu hàm
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    return {
      // SỬA LỖI: Sử dụng biến cục bộ 'prefs' thay vì '_prefs'
      'name': prefs.getString(_userNameKey),
      'avatarPath': prefs.getString(_avatarPathKey),
      'gender': prefs.getString(_genderKey),
      'dob': prefs.getString(_dobKey),
      'city': prefs.getString(_cityKey),
      'style': prefs.getString(_styleKey),
      'currency': prefs.getString(_currencyKey),
      'numberFormat': prefs.getString(_numberFormatKey),
    };
  }

  /// Lưu thông tin profile của người dùng
  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    // SỬA LỖI: Lấy instance của SharedPreferences ở đầu hàm
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    
    // ... logic để lấy dữ liệu từ map `data` ...
    final name = data['name'] as String?;
    final avatarPath = data['avatarPath'] as String?;
    final gender = data['gender'] as String?;
    final dob = data['dob'] as String?;
    final city = data['city'] as String?;
    final style = data['style'] as String?;
    final currency = data['currency'] as String?;
    final numberFormat = data['numberFormat'] as String?;

    // SỬA LỖI: Sử dụng biến cục bộ 'prefs' thay vì '_prefs' cho tất cả các lệnh
    if (name != null && name.isNotEmpty) {
      await prefs.setString(_userNameKey, name);
    } else if (data.containsKey('name')) { // Chỉ xóa nếu key tồn tại
      await prefs.remove(_userNameKey);
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      await prefs.setString(_avatarPathKey, avatarPath);
    } else if (data.containsKey('avatarPath')) {
      await prefs.remove(_avatarPathKey);
    }
    
    // ... (Áp dụng tương tự cho các trường còn lại)
    if (gender != null && gender.isNotEmpty) {
      await prefs.setString(_genderKey, gender);
    } else if (data.containsKey('gender')) {
      await prefs.remove(_genderKey);
    }
    
    if (dob != null && dob.isNotEmpty) {
      await prefs.setString(_dobKey, dob);
    } else if (data.containsKey('dob')) {
      await prefs.remove(_dobKey);
    }

    if (city != null && city.isNotEmpty) {
      await prefs.setString(_cityKey, city);
    } else if (data.containsKey('city')) {
      await prefs.remove(_cityKey);
    }

    if (style != null && style.isNotEmpty) {
      await prefs.setString(_styleKey, style);
    } else if (data.containsKey('style')) {
      await prefs.remove(_styleKey);
    }
    
    if (currency != null && currency.isNotEmpty) {
      await prefs.setString(_currencyKey, currency);
    }

    if (numberFormat != null && numberFormat.isNotEmpty) {
      await prefs.setString(_numberFormatKey, numberFormat);
    }
  }

  /// Lấy thông tin cần thiết cho việc gợi ý trang phục
  Future<Map<String, String?>> getSuggestionInfo() async { // SỬA LỖI: Thêm `async`
    // SỬA LỖI: Lấy instance của SharedPreferences ở đầu hàm
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    return {
      // SỬA LỖI: Sử dụng biến cục bộ 'prefs' thay vì '_prefs'
      'city': prefs.getString(_cityKey),
      'gender': prefs.getString(_genderKey),
      'style': prefs.getString(_styleKey),
    };
  }
}