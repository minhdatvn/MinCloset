// lib/widgets/quest_mascot.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';

class QuestMascot extends ConsumerWidget {
  const QuestMascot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotState = ref.watch(questMascotProvider);
    final mascotNotifier = ref.read(questMascotProvider.notifier);

    // Nếu không hiển thị hoặc không có vị trí, trả về widget trống
    if (!mascotState.isVisible) {
      return const SizedBox.shrink();
    }
    
    // Lấy kích thước màn hình
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // --- BẮT ĐẦU THAY ĐỔI CẤU TRÚC WIDGET ---
    final child = Stack(
      clipBehavior: Clip.none, // Cho phép widget con tràn ra ngoài
      alignment: Alignment.center,
      children: [
        // Ảnh mascot
        Image.asset(
          'assets/images/mascot.webp',
          width: 80,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.flutter_dash, size: 60, color: Colors.blue);
          },
        ),
        // Nút 'X' để đóng
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: mascotNotifier.dismiss, // Gọi hàm dismiss mới
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
        // Thông báo nhiệm vụ mới
        if (mascotState.showQuestNotification)
          Positioned(
            top: -18, // Đặt thông báo phía trên đầu mascot
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Text(
                'New Quests!',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );

    // Bọc Draggable trong GestureDetector để xử lý onTap
    return Positioned(
      left: mascotState.position?.dx,
      top: mascotState.position?.dy,
      child: GestureDetector(
        onTap: () {
          // 1. Chuyển đến trang nhiệm vụ
          Navigator.of(context).pushNamed(AppRoutes.quests);
          // 2. Ẩn thông báo để nó không hiện lại
          mascotNotifier.hideQuestNotification();
        },
        child: Draggable(
          feedback: child,
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            // ... (toàn bộ logic onDragEnd giữ nguyên như cũ)
            double newDx = details.offset.dx;
            double newDy = details.offset.dy;

            final mascotWidth = 80.0;
            final mascotHeight = 80.0;
            if (newDx < 0) newDx = 0;
            if (newDx > screenWidth - mascotWidth) newDx = screenWidth - mascotWidth;
            if (newDy < 0) newDy = 0;
            if (newDy > screenHeight - mascotHeight) newDy = screenHeight - mascotHeight;
            
            final double centerDx = newDx + mascotWidth / 2;
            final double distanceToLeft = centerDx;
            final double distanceToRight = screenWidth - centerDx;

            if (distanceToLeft < distanceToRight) {
              newDx = 0;
            } else {
              newDx = screenWidth - mascotWidth;
            }
            
            mascotNotifier.updatePosition(Offset(newDx, newDy));
          },
          child: child,
        ),
      ),
    );
    // --- KẾT THÚC THAY ĐỔI CẤU TRÚC WIDGET ---
  }
}