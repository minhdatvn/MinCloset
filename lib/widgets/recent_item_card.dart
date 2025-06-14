// file: lib/widgets/recent_item_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class RecentItemCard extends StatelessWidget {
  final ClothingItem item;

  const RecentItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Chiều rộng cố định cho mỗi card
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      // ClipRRect để đảm bảo ảnh cũng được bo góc theo container
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(item.imagePath),
          fit: BoxFit.cover, // Ảnh sẽ được phóng to để lấp đầy card
        ),
      ),
    );
  }
}