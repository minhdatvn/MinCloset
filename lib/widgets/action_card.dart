// lib/widgets/action_card.dart
import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: AspectRatio( // 1. Bọc trong AspectRatio để đảm bảo thẻ luôn là hình vuông
        aspectRatio: 1 / 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(8), // Giảm padding một chút
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              // 2. Căn giữa nội dung
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 28, // Tăng kích thước icon
                ),
                const SizedBox(height: 8), // Thêm khoảng cách giữa icon và chữ
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, // Chữ đậm hơn một chút
                  ),
                  textAlign: TextAlign.center, // Căn giữa chữ
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}