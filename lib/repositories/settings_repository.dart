// lib/repositories/settings_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Repository để quản lý việc truy cập dữ liệu cài đặt người dùng.
/// Lớp này trừu tượng hóa SharedPreferences để các tầng trên (Use Case, Notifier)
/// không cần biết chi tiết về cách lưu trữ.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const _userNameKey = 'user_name';
  static const _avatarPathKey = 'avatar_path';
  static const _genderKey = 'user_gender';
  static const _dobKey = 'user_dob';
  static const _cityKey = 'user_city';
  static const _styleKey = 'user_style';

  /// Lấy toàn bộ thông tin profile của người dùng
  Map<String, dynamic> getUserProfile() {
    return {
      'name': _prefs.getString(_userNameKey),
      'avatarPath': _prefs.getString(_avatarPathKey),
      'gender': _prefs.getString(_genderKey),
      'dob': _prefs.getString(_dobKey),
      'city': _prefs.getString(_cityKey),
      'style': _prefs.getString(_styleKey),
    };
  }

  /// Lưu thông tin profile của người dùng
  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    final name = data['name'] as String?;
    final avatarPath = data['avatarPath'] as String?;
    final gender = data['gender'] as String?;
    final dob = data['dob'] as String?;
    final city = data['city'] as String?;
    final style = data['style'] as String?;

    if (name != null && name.isNotEmpty) {
      await _prefs.setString(_userNameKey, name);
    } else {
      await _prefs.remove(_userNameKey);
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      await _prefs.setString(_avatarPathKey, avatarPath);
    } else {
      await _prefs.remove(_avatarPathKey);
    }
    
    if (gender != null && gender.isNotEmpty) {
      await _prefs.setString(_genderKey, gender);
    } else {
      await _prefs.remove(_genderKey);
    }
    
    if (dob != null && dob.isNotEmpty) {
      await _prefs.setString(_dobKey, dob);
    } else {
      await _prefs.remove(_dobKey);
    }

    if (city != null && city.isNotEmpty) {
      await _prefs.setString(_cityKey, city);
    } else {
      await _prefs.remove(_cityKey);
    }

    if (style != null && style.isNotEmpty) {
      await _prefs.setString(_styleKey, style);
    } else {
      await _prefs.remove(_styleKey);
    }
  }

  /// Lấy thông tin cần thiết cho việc gợi ý trang phục
  Map<String, String?> getSuggestionInfo() {
    return {
      'city': _prefs.getString(_cityKey),
      'gender': _prefs.getString(_genderKey),
      'style': _prefs.getString(_styleKey),
    };
  }
}