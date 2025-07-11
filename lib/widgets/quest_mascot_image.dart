// lib/widgets/quest_mascot_image.dart
import 'package:flutter/material.dart';

class QuestMascotImage extends StatelessWidget {
  const QuestMascotImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mascot.webp',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.flutter_dash, size: 60, color: Colors.blue);
      },
    );
  }
}