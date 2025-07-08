// lib/helpers/ui_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Hiển thị một dialog với hiệu ứng mờ dần và phóng to.
/// Đây là hàm thay thế cho [showDialog] mặc định.
Future<T?> showAnimatedDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 350), // Thời gian hiệu ứng
    pageBuilder: (context, animation1, animation2) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Sử dụng flutter_animate để tạo hiệu ứng
      return child.animate()
          .fade(duration: 350.ms, curve: Curves.easeOutCubic)
          .scale(
            begin: const Offset(0.9, 0.9), 
            end: const Offset(1, 1), 
            curve: Curves.easeOutCubic
          );
    },
  );
}