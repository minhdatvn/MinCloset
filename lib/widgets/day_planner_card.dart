// lib/widgets/day_planner_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayPlannerCard extends StatelessWidget {
  final String dayLabel;
  final DateTime date;
  final bool isToday;
  final List<String> itemImagePaths;
  final VoidCallback onAdd;

  const DayPlannerCard({
    super.key,
    required this.dayLabel,
    required this.date,
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
          const SizedBox(height: 2), // Thêm một khoảng cách nhỏ
          Text(
            DateFormat('d/M').format(date), // Định dạng ngày/tháng
            style: TextStyle(
              fontSize: 12,
              color: isToday
                  ? theme.colorScheme.primary.withAlpha(200)
                  : theme.colorScheme.onSurface.withAlpha(150),
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

    return GridView.builder(
      // Vô hiệu hóa việc cuộn của GridView, để ListView bên ngoài xử lý
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Luôn hiển thị 2 cột
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        // Giữ tỷ lệ ảnh là 3/4
        childAspectRatio: 3 / 4,
      ),
      itemCount: displayImages.length,
      itemBuilder: (context, index) {
        final path = displayImages[index];
        return Container(
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
        );
      },
    );
  }
}