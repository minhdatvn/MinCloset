// lib/screens/edit_closet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart'; 

// --- Định nghĩa sẵn các Icon và Màu sắc để chọn ---
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

// --- Bắt đầu Widget ---
class EditClosetScreen extends ConsumerStatefulWidget {
  final Closet closet;
  const EditClosetScreen({super.key, required this.closet});

  @override
  ConsumerState<EditClosetScreen> createState() => _EditClosetScreenState();
}

class _EditClosetScreenState extends ConsumerState<EditClosetScreen> {
  late TextEditingController _nameController;
  late String _selectedIconName;
  late String _selectedColorHex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.closet.name);
    _selectedIconName = widget.closet.iconName ?? 'Default';
    _selectedColorHex = widget.closet.colorHex ?? '#FFFFFF';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // 1. Tạo đối tượng closet đã cập nhật từ state của màn hình
    final updatedCloset = widget.closet.copyWith(
      name: _nameController.text.trim(),
      iconName: _selectedIconName,
      colorHex: _selectedColorHex,
    );

    // 2. Gọi notifier để thực hiện logic lưu trữ
    ref.read(closetsPageProvider.notifier).updateClosetDetails(updatedCloset);
    
    // 3. Đóng màn hình lại
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Closet'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Sửa Tên ---
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Closet Name',
              border: OutlineInputBorder(),
            ),
            maxLength: 30,
          ),
          const SizedBox(height: 24),

          // --- Chọn Icon ---
          const Text('Choose Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

          // --- Chọn Màu ---
          const Text('Choose Card Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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