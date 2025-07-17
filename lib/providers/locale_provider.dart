// lib/providers/locale_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider này sẽ quản lý ngôn ngữ hiện tại của ứng dụng
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  // Hàm khởi tạo không thay đổi, vì _loadLocale sẽ ghi đè trạng thái ngay sau đó.
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  // Tải ngôn ngữ đã lưu từ bộ nhớ, với logic được cải tiến
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString('language_code');

    // 1. Nếu người dùng ĐÃ từng chọn ngôn ngữ trong app
    if (savedLangCode != null && savedLangCode.isNotEmpty) {
      state = Locale(savedLangCode);
      return; // Dừng lại ở đây
    }

    // 2. Nếu người dùng CHƯA chọn ngôn ngữ, lấy ngôn ngữ hệ thống
    // Platform.localeName sẽ trả về dạng "vi_VN", "en_US",...
    final String systemLocaleName = Platform.localeName; 
    final String systemLangCode = systemLocaleName.split('_').first; // Lấy ra "vi", "en",...

    // 3. Kiểm tra xem ngôn ngữ hệ thống có được hỗ trợ không (en, vi)
    const supportedLocales = ['en', 'vi']; 
    if (supportedLocales.contains(systemLangCode)) {
      state = Locale(systemLangCode);
    } else {
      // 4. Nếu không, mới dùng tiếng Anh làm mặc định cuối cùng
      state = const Locale('en');
    }
  }

  void setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    state = Locale(langCode);
  }
}