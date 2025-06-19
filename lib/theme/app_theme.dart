// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// 1. Định nghĩa các màu sắc cốt lõi của bạn
const Color mochaMousse = Color(0xFF755D4C); // Màu nhấn chính (Màu của năm 2025)
const Color almostBlack = Color(0xFF1C1C1E); // Màu đen tuyền cho chữ và các yếu tố chính
const Color lightGray = Color(0xFFF2F2F7);   // Màu xám rất nhạt cho nền của các thẻ
const Color midGray = Color(0xFFE5E5EA);     // Màu xám cho đường viền

// 2. Tạo đối tượng ThemeData để Flutter sử dụng
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Helvetica', 

  // Thiết lập bảng màu chính
  colorScheme: ColorScheme.fromSeed(
    seedColor: mochaMousse,
    primary: mochaMousse,
    brightness: Brightness.light,
    surface: Colors.white,
    onSurface: almostBlack,
    surfaceContainerHighest: lightGray,
    outline: midGray,
  ),

  scaffoldBackgroundColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: almostBlack,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Helvetica',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: almostBlack,
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: lightGray,
    disabledColor: lightGray,
    selectedColor: mochaMousse.withAlpha(50),
    labelStyle: const TextStyle(color: almostBlack, fontWeight: FontWeight.w500),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    shape: const StadiumBorder(),
    side: BorderSide.none,
    showCheckmark: false,
  ),

  // <<< SỬA ĐỔI Ở ĐÂY >>>
  // Giao diện cho nút bấm chính
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: mochaMousse, // Đổi màu nền mặc định thành màu chủ đạo
      foregroundColor: Colors.white, // Chữ trắng trên nền màu chủ đạo
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      elevation: 2,
    ),
  ),
);