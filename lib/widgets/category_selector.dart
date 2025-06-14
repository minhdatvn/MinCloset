// file: lib/widgets/category_selector.dart

import 'package:flutter/material.dart';
import 'package:mincloset/constants/app_options.dart';

class CategorySelector extends StatefulWidget {
  final String? initialCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    this.initialCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _selectedMainCategory;
  String? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    // Tách giá trị ban đầu (ví dụ: "Áo (Tops) > Áo thun") thành 2 phần
    if (widget.initialCategory != null && widget.initialCategory!.contains(' > ')) {
      final parts = widget.initialCategory!.split(' > ');
      _selectedMainCategory = parts[0];
      _selectedSubCategory = parts[1];
    }
  }

  void _selectMainCategory(String category) {
    setState(() {
      _selectedMainCategory = category;
      _selectedSubCategory = null; // Reset lựa chọn con khi chọn lại cha
    });
  }

  void _selectSubCategory(String subCategory) {
    setState(() {
      _selectedSubCategory = subCategory;
    });
    // Gửi kết quả cuối cùng về cho trang cha
    widget.onCategorySelected('$_selectedMainCategory > $_selectedSubCategory');
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa chọn danh mục cha, hiển thị danh sách các danh mục cha
    if (_selectedMainCategory == null) {
      return Wrap(
        spacing: 8.0,
        children: AppOptions.categories.keys.map((mainCategory) {
          return ActionChip(
            label: Text(mainCategory),
            onPressed: () => _selectMainCategory(mainCategory),
          );
        }).toList(),
      );
    }

    // Nếu đã chọn danh mục cha, hiển thị nó và danh sách các danh mục con
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị danh mục cha đã chọn
        InputChip(
          label: Text(_selectedMainCategory!),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          selected: true,
          onDeleted: () {
            setState(() {
              _selectedMainCategory = null;
              _selectedSubCategory = null;
            });
            widget.onCategorySelected(''); // Xóa lựa chọn
          },
          deleteIcon: const Icon(Icons.close, size: 18),
        ),
        const Divider(height: 16),
        // Hiển thị danh sách danh mục con
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: AppOptions.categories[_selectedMainCategory]!.map((subCategory) {
            return FilterChip(
              label: Text(subCategory),
              selected: _selectedSubCategory == subCategory,
              onSelected: (selected) {
                if (selected) {
                  _selectSubCategory(subCategory);
                }
              },
              selectedColor: Colors.deepPurple.withAlpha(51),
              checkmarkColor: Colors.deepPurple,
            );
          }).toList(),
        ),
      ],
    );
  }
}