// lib/widgets/section_header.dart

import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllText; // <<< THÊM THAM SỐ MỚI
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllText, // <<< THÊM VÀO CONSTRUCTOR
    this.actionIcon,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                // <<< SỬ DỤNG THAM SỐ MỚI HOẶC GIÁ TRỊ MẶC ĐỊNH
                Text(seeAllText ?? 'See all'),
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