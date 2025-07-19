// lib/widgets/tip_card.dart
import 'package:flutter/material.dart';

/// Một Card có thể tái sử dụng để hiển thị một mục hướng dẫn (tip).
/// Bao gồm ảnh/icon, tiêu đề và mô tả.
class TipCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;
  final IconData? icon;

  const TipCard({
    super.key,
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Phần hiển thị ảnh hoặc icon
            SizedBox(
              width: 60,
              height: 60,
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.help_outline, size: 40),
                    )
                  : Icon(icon ?? Icons.help_outline, size: 40),
            ),
            const SizedBox(width: 16),
            // Phần hiển thị tiêu đề và mô tả
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}