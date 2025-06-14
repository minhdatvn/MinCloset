// file: lib/widgets/editable_season_row.dart

import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';

class EditableSeasonRow extends StatefulWidget {
  final ClothingItem item;
  final Function(ClothingItem) onUpdate; // Callback để báo cho trang cha biết khi có cập nhật

  const EditableSeasonRow({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<EditableSeasonRow> createState() => _EditableSeasonRowState();
}

class _EditableSeasonRowState extends State<EditableSeasonRow> {
  bool _isExpanded = false;
  final List<String> _allSeasons = ['Xuân', 'Hạ', 'Thu', 'Đông'];
  // Dùng Set để lưu các mùa đã chọn, giúp tránh trùng lặp
  late Set<String> _selectedSeasons;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các mùa đã chọn từ dữ liệu của món đồ
    final initialSeasons = widget.item.season?.split(', ') ?? [];
    _selectedSeasons = Set<String>.from(initialSeasons);
  }

  // Hàm xử lý khi một nút mùa được nhấn
  void _handleSelection(String season) async {
    setState(() {
      if (_selectedSeasons.contains(season)) {
        _selectedSeasons.remove(season);
      } else {
        _selectedSeasons.add(season);
      }
    });

    // Tạo một đối tượng item mới với thông tin mùa đã được cập nhật
    final updatedItem = ClothingItem(
      id: widget.item.id,
      name: widget.item.name,
      category: widget.item.category,
      color: widget.item.color,
      imagePath: widget.item.imagePath,
      closetId: widget.item.closetId,
      // Chuyển Set thành một chuỗi String, ví dụ: "Xuân, Thu"
      season: _selectedSeasons.join(', '),
      occasion: widget.item.occasion,
      material: widget.item.material,
      pattern: widget.item.pattern,
    );
    
    // Tự động lưu vào CSDL
    await DatabaseHelper.instance.updateItem(updatedItem);
    // Gọi callback để cập nhật trạng thái ở trang cha
    widget.onUpdate(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    // Giá trị hiển thị khi ở trạng thái đóng
    final displayValue = _selectedSeasons.isEmpty ? 'Chọn mùa' : _selectedSeasons.join(', ');

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mùa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(
                      displayValue,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Nếu đang mở rộng, hiển thị các nút chọn
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8.0, // Khoảng cách ngang giữa các nút
              runSpacing: 4.0, // Khoảng cách dọc giữa các hàng
              children: _allSeasons.map((season) {
                return FilterChip(
                  label: Text(season),
                  selected: _selectedSeasons.contains(season),
                  onSelected: (isSelected) {
                    _handleSelection(season);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}