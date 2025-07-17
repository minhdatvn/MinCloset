// lib/widgets/achievement_unlocked_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mincloset/helpers/context_extensions.dart';
// THAY ĐỔI 1: Thêm tiền tố 'model' cho import
import 'package:mincloset/models/badge.dart' as model;

class AchievementUnlockedDialog extends StatelessWidget {
  // THAY ĐỔI 2: Cập nhật kiểu dữ liệu của badge
  final model.Badge badge;

  const AchievementUnlockedDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.achievementDialog_title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          Image.asset(
            badge.imagePath,
            width: 120,
            height: 120,
            errorBuilder: (ctx, err, st) => const Icon(Icons.shield, size: 120),
          )
              .animate()
              .scale(
                  delay: 300.ms,
                  duration: 600.ms,
                  curve: Curves.elasticOut)
              .then()
              .shimmer(duration: 1200.ms),
          const SizedBox(height: 16),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.achievementDialog_button),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}