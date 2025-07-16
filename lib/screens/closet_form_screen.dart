// lib/screens/closet_form_screen.dart (tên file mới)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/providers/ui_providers.dart';

// --- THAY ĐỔI 1: Tách các Icon và Màu sắc ra khỏi widget để dễ quản lý ---
const Map<String, IconData> _availableIcons = {
  'Default': Icons.style_outlined,
  'Work': Icons.business_center_outlined,
  'Gym': Icons.fitness_center_outlined,
  'Travel': Icons.flight_takeoff_outlined,
  'Home': Icons.home_outlined,
  'Party': Icons.celebration_outlined,
  'Formal': Icons.theater_comedy_outlined,
};

const List<String> _availableColors = [
  '#FFFFFF', // Default
  '#FFCDD2', // Light Red
  '#E1BEE7', // Light Purple
  '#BBDEFB', // Light Blue
  '#C8E6C9', // Light Green
  '#FFF9C4', // Light Yellow
  '#FFCCBC', // Light Orange
  '#D7CCC8', // Light Brown
];

// --- THAY ĐỔI 2: Đổi tên widget và cập nhật constructor ---
class ClosetFormScreen extends ConsumerStatefulWidget {
  // `closetToEdit` giờ đây là nullable. Nếu nó null, ta hiểu là đang ở chế độ "Thêm mới".
  final Closet? closetToEdit; 
  const ClosetFormScreen({super.key, this.closetToEdit});

  @override
  ConsumerState<ClosetFormScreen> createState() => _ClosetFormScreenState();
}

class _ClosetFormScreenState extends ConsumerState<ClosetFormScreen> {
  late TextEditingController _nameController;
  late String _selectedIconName;
  late String _selectedColorHex;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    // Xác định xem có đang ở chế độ sửa không
    _isEditing = widget.closetToEdit != null;
    
    // Khởi tạo các giá trị ban đầu
    _nameController = TextEditingController(text: widget.closetToEdit?.name ?? '');
    _selectedIconName = widget.closetToEdit?.iconName ?? 'Default';
    _selectedColorHex = widget.closetToEdit?.colorHex ?? '#FFFFFF';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final l10n = context.l10n;
    final notifier = ref.read(closetsPageProvider.notifier);
    final name = _nameController.text.trim();

    if (_isEditing) {
      // Nếu là chế độ sửa, tạo một đối tượng mới với ID cũ
      final updatedCloset = widget.closetToEdit!.copyWith(
        name: name,
        iconName: _selectedIconName,
        colorHex: _selectedColorHex,
      );
      notifier.updateClosetDetails(updatedCloset, l10n: l10n);
    } else {
      // Nếu là chế độ thêm, gọi hàm addCloset với các thông tin đã chọn
      notifier.addCloset(
        name,
        iconName: _selectedIconName,
        colorHex: _selectedColorHex,
        l10n: l10n,
      );
      // Bổ sung logic điều hướng
      // 1. Chuyển trang chính đến tab "Closets" (index = 1)
      ref.read(mainScreenIndexProvider.notifier).state = 1;
      // 2. Chỉ định cho trang Closets hiển thị tab "By Closet" (index = 1)
      ref.read(closetsSubTabIndexProvider.notifier).state = 1;
    }
    
    // Sau khi lưu, đóng màn hình lại
    Navigator.of(context).pop();
  }
  
  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.closetForm_titleEdit : l10n.closetForm_titleAdd),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(l10n.closetForm_saveButton, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.closetForm_nameLabel,
              border: OutlineInputBorder(),
            ),
            maxLength: 30,
          ),
          const SizedBox(height: 24),
          Text(l10n.closetForm_iconLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableIcons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final iconName = _availableIcons.keys.elementAt(index);
              final iconData = _availableIcons[iconName]!;
              final isSelected = iconName == _selectedIconName;

              return InkWell(
                onTap: () => setState(() => _selectedIconName = iconName),
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(50) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    )
                  ),
                  child: Icon(iconData, size: 32, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade700),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.closetForm_colorLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableColors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final colorHex = _availableColors[index];
              final isSelected = colorHex == _selectedColorHex;

              return InkWell(
                onTap: () => setState(() => _selectedColorHex = colorHex),
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: _colorFromHex(colorHex),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                      width: isSelected ? 3 : 1,
                    )
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.black54) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}