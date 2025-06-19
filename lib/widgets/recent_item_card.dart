// lib/widgets/recent_item_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class RecentItemCard extends StatelessWidget {
  final ClothingItem item;
  final int count;

  const RecentItemCard({
    super.key,
    required this.item,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    // BƯỚC 1: Dùng AspectRatio để tạo một khung 3:4 cố định.
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // BƯỚC 2: Vẽ lớp nền (background) trước tiên.
          // Container này sẽ tự động lấp đầy không gian của Stack (và AspectRatio).
          // Nó có bo góc và viền.
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),

          // BƯỚC 3: Vẽ lớp nội dung (ảnh) lên trên lớp nền.
          // Dùng Padding để tạo khoảng đệm cho ảnh so với viền.
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Bo góc cho chính hình ảnh
              child: Image.file(
                File(item.imagePath),
                // BoxFit.contain đảm bảo ảnh hiển thị đầy đủ, không bị cắt xén,
                // và được co lại để vừa với không gian của Padding.
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

          // Lớp Badge số đếm không thay đổi, được đặt lên trên cùng.
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
            ),
        ],
      ),
    );
  }
}