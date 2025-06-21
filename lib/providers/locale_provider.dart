// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider này sẽ quản lý ngôn ngữ hiện tại của ứng dụng
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  // Ngôn ngữ mặc định khi mở app lần đầu là Tiếng Việt
  LocaleNotifier() : super(const Locale('vi')) {
    _loadLocale();
  }

  // Tải ngôn ngữ đã lưu từ bộ nhớ
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'vi';
    state = Locale(langCode);
  }

  // Đặt ngôn ngữ mới và lưu vào bộ nhớ
  void setLocale(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    state = Locale(langCode);
  }
}