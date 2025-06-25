// lib/widgets/recent_item_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class RecentItemCard extends StatelessWidget {
  final ClothingItem item;
  final int count;
  final bool isSelected; // <<< THÊM MỚI: Trạng thái được chọn

  const RecentItemCard({
    super.key,
    required this.item,
    this.count = 0,
    this.isSelected = false, // <<< THÊM MỚI
  });

  @override
  Widget build(BuildContext context) {
    final imageToShowPath = item.thumbnailPath ?? item.imagePath;

    // <<< SỬA ĐỔI: Thêm hiệu ứng viền và overlay khi được chọn >>>
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Viền sẽ có màu primary khi được chọn
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1.0,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(imageToShowPath),
                  fit: BoxFit.contain,
                  key: ValueKey(imageToShowPath),
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40));
                  },
                ),
              ),
            ),
            // Lớp phủ mờ và icon check khi được chọn
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:100),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle, color: Colors.white, size: 32),
                ),
              ),
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
      ),
    );
  }
}