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

    if (!mascotState.isVisible || mascotState.position == null) {
      return const SizedBox.shrink();
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // SỬA LỖI: Định nghĩa mascotImage ở phạm vi cao hơn để tất cả các widget con có thể truy cập
    final mascotImage = Image.asset(
      'assets/images/mascot.webp',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.flutter_dash, size: 60, color: Colors.blue);
      },
    );

    final child = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.quests);
            mascotNotifier.hideNotification();
          },
          child: mascotImage, // Sử dụng biến đã định nghĩa
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: mascotNotifier.dismiss,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        if (mascotState.showNotification)
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: mascotNotifier.hideNotification,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                child: Text(
                  mascotState.notificationText,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );

    return Positioned(
      left: mascotState.position!.dx,
      top: mascotState.position!.dy,
      child: Draggable(
        feedback: mascotImage, // Bây giờ có thể truy cập biến này
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
            double newDx = details.offset.dx;
            double newDy = details.offset.dy;

            final mascotWidth = 80.0;
            final mascotHeight = 80.0;
            if (newDx < 0) newDx = 0;
            if (newDx > screenWidth - mascotWidth) {
              newDx = screenWidth - mascotWidth;
            }
            if (newDy < 0) newDy = 0;
            if (newDy > screenHeight - mascotHeight) {
              newDy = screenHeight - mascotHeight;
            }
            
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
    );
  }
}