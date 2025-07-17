// lib/widgets/section_header.dart

import 'package:flutter/material.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllText;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllText,
    this.actionIcon,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              children: [
                Text(seeAllText ?? l10n.common_seeAll),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          )
        else if (actionIcon != null)
          IconButton(
            onPressed: onActionPressed,
            icon: Icon(actionIcon, color: Colors.grey.shade700),
          ),
      ],
    );
  }
}