// lib/widgets/stats_overview_card.dart
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class StatsOverviewCard extends StatelessWidget {
  final int totalItems;
  final int totalClosets;
  final int totalOutfits;

  const StatsOverviewCard({
    super.key,
    required this.totalItems,
    required this.totalClosets,
    required this.totalOutfits,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context: context,
              label: l10n.stats_label_item(totalItems),
              value: totalItems.toString(),
            ),
            _buildStatItem(
              context: context,
              label: l10n.stats_label_closet(totalClosets),
              value: totalClosets.toString(),
            ),
            _buildStatItem(
              context: context,
              label: l10n.stats_label_outfit(totalOutfits),
              value: totalOutfits.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            // <<< SỬA LỖI Ở ĐÂY >>>
            color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}