// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

// 1. Định nghĩa các màu sắc cốt lõi của bạn
const Color mintyTeal = Color(0xFF1ABC9C);    // Màu nhấn chính (Xanh bạc hà)
const Color almostBlack = Color(0xFF1C1C1E); // Màu đen tuyền cho chữ và các yếu tố chính
const Color faintGray = Color(0xFFF5F5F5);   // Màu xám rất nhạt cho nền của các thẻ
const Color lightBorderGray = Color(0xFFE0E0E0); 

// 2. Tạo đối tượng ThemeData để Flutter sử dụng
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'BeVietnamPro', 

  // Thiết lập bảng màu chính
  colorScheme: ColorScheme.fromSeed(
    seedColor: mintyTeal,
    primary: mintyTeal,
    brightness: Brightness.light,
    surface: Colors.white,
    onSurface: almostBlack,
    surfaceContainerHighest: faintGray,
    outline: lightBorderGray,
    // Màu surfaceTint được dùng để tạo hiệu ứng phủ màu trên các bề mặt,
    // giúp chúng có chiều sâu hoặc tương tác tốt hơn với màu chính.
    surfaceTint: mintyTeal, 
  ),

  scaffoldBackgroundColor: Colors.white,

  // Định nghĩa TextTheme để kiểm soát kích thước và trọng lượng font
  textTheme: const TextTheme(
    displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.normal, color: almostBlack), // Giảm size so với mặc định
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: almostBlack), // Giảm size từ 24 xuống 22
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: almostBlack),    // Giảm size từ 22 xuống 18
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: almostBlack),   // Giữ nguyên hoặc điều chỉnh nhẹ
    bodyLarge: TextStyle(fontSize: 16, color: almostBlack),                                  // Giữ nguyên
    bodyMedium: TextStyle(fontSize: 14, color: almostBlack),                                  // Giữ nguyên
    bodySmall: TextStyle(fontSize: 12, color: almostBlack),                                   // Giữ nguyên
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),    // Cho nút bấm
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: almostBlack,
    elevation: 0,
    centerTitle: false,
    // Sử dụng TextStyle từ TextTheme để nhất quán
    titleTextStyle: const TextStyle(
      fontFamily: 'BeVietnamPro',
      fontSize: 18, // Thay đổi fontSize cho AppBar
      fontWeight: FontWeight.bold,
      color: almostBlack,
    ),
    // Thêm surfaceTintColor để tạo điểm nhấn
    surfaceTintColor: mintyTeal.withValues(alpha:0.05),
  ),

  // SỬA LỖI TẠI ĐÂY: Thay CardTheme thành CardThemeData
  cardTheme: CardThemeData(
    elevation: 0, // Bỏ elevation cho Card để giao diện phẳng hơn
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Bo góc cho Card
    ),
    color: faintGray, // Màu nền mặc định cho Card
    surfaceTintColor: mintyTeal.withValues(alpha:0.05), // Thêm hiệu ứng màu cho Card
  ),

  chipTheme: ChipThemeData(
    backgroundColor: faintGray,
    disabledColor: faintGray,
    selectedColor: mintyTeal.withAlpha(50),
    labelStyle: const TextStyle(color: almostBlack, fontWeight: FontWeight.w500),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    shape: const StadiumBorder(),
    side: BorderSide.none,
    showCheckmark: false,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: mintyTeal, 
      foregroundColor: Colors.white, 
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 14, // Thay đổi fontSize cho ElevatedButton
        fontWeight: FontWeight.bold,
      ),
      elevation: 2,
    ),
  ),
);