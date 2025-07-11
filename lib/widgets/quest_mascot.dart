// lib/widgets/quest_mascot.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/widgets/quest_mascot_image.dart';

class QuestMascot extends ConsumerWidget {
  const QuestMascot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotState = ref.watch(questMascotProvider);
    final mascotNotifier = ref.read(questMascotProvider.notifier);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // THAY ĐỔI 2: Xóa GestureDetector ở đây, chỉ còn lại ảnh
        const QuestMascotImage(),

        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: mascotNotifier.dismiss,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        
        if (mascotState.notificationType != MascotNotificationType.none)
          Positioned(
            top: -22,
            child: GestureDetector(
              onTap: mascotNotifier.hideCurrentNotification,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  mascotState.notificationMessage,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}