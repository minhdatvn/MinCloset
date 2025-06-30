// lib/widgets/day_planner_card.dart
import 'dart:io';
import 'package:flutter/material.dart';

class DayPlannerCard extends StatelessWidget {
  final String dayLabel;
  final bool isToday;
  final IconData weatherIcon;
  final String temperature;
  final List<String> itemImagePaths; // Danh sách đường dẫn ảnh
  final VoidCallback onAdd;

  const DayPlannerCard({
    super.key,
    required this.dayLabel,
    this.isToday = false,
    required this.weatherIcon,
    required this.temperature,
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
          // --- Phần Ngày và Thời tiết ---
          Text(
            dayLabel,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Icon(weatherIcon, color: theme.colorScheme.onSurface, size: 20),
          const SizedBox(height: 4),
          Text(
            temperature,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

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
    final displayImages = itemImagePaths.take(2).toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: displayImages.map((path) {
          // <<< THAY ĐỔI: Dùng Image.file thay vì Image.asset >>>
          return Image.file(File(path), width: 40, height: 40, fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Icon(Icons.error_outline),
          );
        }).toList(),
      ),
    );
  }
}