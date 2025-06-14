// file: lib/widgets/section_header.dart

import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll; // Dùng VoidCallback cho các sự kiện nhấn nút

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null) // Chỉ hiển thị nút "See all" nếu có hành động được truyền vào
          TextButton(
            onPressed: onSeeAll,
            child: const Row(
              children: [
                Text('See all'),
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}