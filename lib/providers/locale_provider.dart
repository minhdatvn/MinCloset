// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider này sẽ quản lý ngôn ngữ hiện tại của ứng dụng
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  // <<< THAY ĐỔI NGÔN NGỮ MẶC ĐỊNH Ở ĐÂY >>>
  // Ngôn ngữ mặc định khi mở app lần đầu là Tiếng Anh
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  // Tải ngôn ngữ đã lưu từ bộ nhớ
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    // Thay giá trị dự phòng ở đây để nhất quán
    final langCode = prefs.getString('language_code') ?? 'en';
    state = Locale(langCode);
  }

  // Đặt ngôn ngữ mới và lưu vào bộ nhớ
  void setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    state = Locale(langCode);
  }
}