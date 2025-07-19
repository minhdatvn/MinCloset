// lib/widgets/help_tooltip_icon.dart
import 'package:flutter/material.dart';

/// Một widget IconButton được tùy chỉnh để hiển thị icon dấu hỏi (?)
/// cho các mục cần hướng dẫn.
class HelpTooltipIcon extends StatelessWidget {
  final VoidCallback onPressed;

  const HelpTooltipIcon({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng InkWell để kiểm soát vùng chạm và hiệu ứng tốt hơn
    return InkWell(
      customBorder: const CircleBorder(), // Hiệu ứng ripple tròn
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Một chút đệm để dễ nhấn
        child: Icon(
          Icons.help_outline,
          color: Colors.grey.shade500,
          size: 20, // Kích thước cố định
        ),
      ),
    );
  }
}