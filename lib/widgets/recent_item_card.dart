// lib/widgets/recent_item_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class RecentItemCard extends StatelessWidget {
  final ClothingItem item;
  final int count; // <<< THÊM THAM SỐ NÀY

  const RecentItemCard({
    super.key,
    required this.item,
    this.count = 0, // Mặc định là 0
  });

  @override
  Widget build(BuildContext context) {
    // <<< SỬ DỤNG STACK ĐỂ ĐẶT BADGE LÊN TRÊN
    return Stack(
      clipBehavior: Clip.none, // Cho phép badge vẽ ra ngoài khung
      children: [
        // Widget Card gốc giữ nguyên
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.file(
                File(item.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // <<< THÊM WIDGET BADGE SỐ ĐẾM
        // Chỉ hiển thị khi count > 0
        if (count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 22,
                minHeight: 22,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
      ],
    );
  }
}