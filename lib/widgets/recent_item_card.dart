// lib/widgets/recent_item_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class RecentItemCard extends StatelessWidget {
  final ClothingItem item;

  const RecentItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Container này không cần set width/height, nó sẽ tự động co giãn theo GridView.
    return Container(
      decoration: BoxDecoration(
        // <<< SỬ DỤNG NỀN TRẮNG
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // Thêm một Padding nhỏ để ảnh không bị dính sát vào viền
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.file(
            File(item.imagePath),
            // <<< THAY ĐỔI QUAN TRỌNG NHẤT: từ .cover sang .contain
            fit: BoxFit.contain,
            // Thêm errorBuilder để xử lý trường hợp file ảnh bị lỗi hoặc bị xóa
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
    );
  }
}