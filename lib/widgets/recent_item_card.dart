// lib/widgets/recent_item_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/models/clothing_item.dart';

class RecentItemCard extends StatelessWidget {
  final ClothingItem item;
  final int count;
  final bool isSelected;

  const RecentItemCard({
    super.key,
    required this.item,
    this.count = 0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageToShowPath = item.thumbnailPath ?? item.imagePath;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      // Clip.antiAlias giúp các widget con bên trong (như ảnh) cũng được bo góc theo
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Lớp 1: Ảnh sản phẩm
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.file(
              File(imageToShowPath),
              fit: BoxFit.contain,
              key: ValueKey(imageToShowPath),
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40));
              },
            ),
          ),

          // Lớp 2: Viền ngoài (chỉ vẽ viền, không có nền)
          // Được đặt trong AnimatedContainer để có hiệu ứng chuyển đổi mượt mà
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent, // Trong suốt khi không được chọn
                width: isSelected ? 2.5 : 1.0,
              ),
            ),
          ),

          // Lớp 3: Lớp phủ và icon check khi được chọn
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha:0.4),
              ),
              child: const Center(
                child: Icon(Icons.check_circle, color: Colors.white, size: 32),
              ),
            ),

          // Lớp 4: Badge đếm số lượng (nếu có)
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