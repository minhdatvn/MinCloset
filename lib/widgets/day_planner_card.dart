// lib/widgets/day_planner_card.dart
import 'dart:io';
import 'package:flutter/material.dart';

class DayPlannerCard extends StatelessWidget {
  final String dayLabel;
  final bool isToday;
  final List<String> itemImagePaths;
  final VoidCallback onAdd;

  const DayPlannerCard({
    super.key,
    required this.dayLabel,
    this.isToday = false,
    required this.itemImagePaths,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          // --- Phần Ngày ---
          Text(
            dayLabel,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // --- Phần Thẻ chứa trang phục ---
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onAdd,
                child: itemImagePaths.isEmpty
                    ? _buildAddPlaceholder(theme)
                    : _buildOutfitPreview(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPlaceholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.calendar_month_outlined,
        color: theme.colorScheme.primary.withAlpha(150),
        size: 32,
      ),
    );
  }

  Widget _buildOutfitPreview() {
    final displayImages = itemImagePaths.take(4).toList();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: displayImages.map((path) {
          // Bọc AspectRatio trong SizedBox để giới hạn kích thước
          return SizedBox(
            // Chiều rộng được tính toán lại chính xác là 45px
            width: 45, 
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5)),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain, // Dùng contain để không bị cắt ảnh
                  errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.error_outline),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}