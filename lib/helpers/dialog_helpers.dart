// lib/helpers/ui_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mincloset/l10n/app_localizations.dart';

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

/// Hiển thị một dialog xác nhận xóa chung.
///
/// Trả về `true` nếu người dùng nhấn "Xóa", ngược lại trả về `false`.
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  required String title,
  required Widget content, // Sử dụng Widget để nội dung có thể linh hoạt
}) async {
  // Lấy l10n một cách an toàn bên trong hàm
  final l10n = AppLocalizations.of(context)!;
  
  // Gọi hàm showAnimatedDialog đã có sẵn
  final bool? confirmed = await showAnimatedDialog<bool>(
    context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        // Nút "Hủy"
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.common_cancel),
        ),
        // Nút "Xóa"
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(l10n.allItems_delete), // Dùng chung một chuỗi "Xóa"
        ),
      ],
    ),
  );
  
  // Trả về false nếu người dùng đóng dialog mà không chọn
  return confirmed ?? false;
}