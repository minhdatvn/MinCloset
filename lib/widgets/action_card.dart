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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Sử dụng màu nền xám nhạt từ theme
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                // Sử dụng màu nhấn Mocha Mousse cho icon
                color: theme.colorScheme.primary,
                size: 24,
              ),
              Text(
                label,
                style: TextStyle(
                  // Sử dụng màu chữ chính từ theme
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}