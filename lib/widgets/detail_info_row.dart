// file: lib/widgets/detail_info_row.dart

import 'package:flutter/material.dart';

class DetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const DetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                if (onTap != null) // Chỉ hiển thị icon nếu có hành động onTap
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}