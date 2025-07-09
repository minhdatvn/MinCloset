// lib/widgets/quest_mascot.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/quest_fab_notifier.dart';

class QuestMascot extends ConsumerWidget {
  const QuestMascot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe state của mascot (vị trí, ẩn/hiện)
    final mascotState = ref.watch(questMascotProvider);
    if (!mascotState.isVisible) {
      return const SizedBox.shrink();
    }

    // Lấy kích thước màn hình
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Widget chứa hình ảnh chú chim
    final child = Stack(
      alignment: Alignment.center,
      children: [
        // HÌNH ẢNH CHÚ CHIM
        Image.asset(
          'assets/images/mascot.webp', // <-- THAY THẾ BẰNG PATH CỦA BẠN
          width: 80, // Kích thước của mascot
          height: 80,
          // Nếu chưa có ảnh, dùng icon placeholder
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.flutter_dash, size: 60, color: Colors.blue);
          },
        ),
        // NÚT 'X' ĐỂ ĐÓNG
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => ref.read(questMascotProvider.notifier).dismiss(),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );

    // Bọc chú chim trong Draggable để cho phép kéo thả
    return Positioned(
      left: mascotState.position.dx,
      top: mascotState.position.dy,
      child: Draggable(
        feedback: child, // Widget hiển thị khi đang kéo
        childWhenDragging: const SizedBox.shrink(), // Ẩn widget gốc khi đang kéo
        // Khi kéo xong
        onDragEnd: (details) {
          // Lấy vị trí cuối cùng sau khi thả tay
          double newDx = details.offset.dx;
          double newDy = details.offset.dy;

          // Giới hạn vị trí không bị kéo ra ngoài màn hình
          final mascotWidth = 80.0;
          final mascotHeight = 80.0;
          if (newDx < 0) newDx = 0;
          if (newDx > screenWidth - mascotWidth) newDx = screenWidth - mascotWidth;
          if (newDy < 0) newDy = 0;
          if (newDy > screenHeight - mascotHeight) newDy = screenHeight - mascotHeight;
          
          // --- LOGIC "NAM CHÂM" ---
          // Tính khoảng cách từ tâm của mascot đến 2 cạnh bên
          final double centerDx = newDx + mascotWidth / 2;
          final double distanceToLeft = centerDx;
          final double distanceToRight = screenWidth - centerDx;

          // Nếu khoảng cách đến cạnh trái nhỏ hơn, "hút" về bên trái
          if (distanceToLeft < distanceToRight) {
            newDx = 0;
          } else {
            // Ngược lại, "hút" về bên phải
            newDx = screenWidth - mascotWidth;
          }
          
          // Cập nhật và lưu lại vị trí mới
          ref.read(questMascotProvider.notifier).updatePosition(Offset(newDx, newDy));
        },
        child: child, // Widget gốc khi chưa kéo
      ),
    );
  }
}