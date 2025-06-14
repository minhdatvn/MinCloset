// file: lib/widgets/section_header.dart

import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  // Thêm 2 thuộc tính mới
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.actionIcon, // Thêm vào constructor
    this.onActionPressed, // Thêm vào constructor
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
        // Hiển thị nút See All hoặc nút Action
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Row(
              children: [
                Text('See all'),
                Icon(Icons.arrow_forward_ios, size: 14),
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