// lib/widgets/category_selector.dart

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
  bool _isExpanded = false;
  String? _selectedMainCategory;
  String? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _updateCategoryFromWidget(widget.initialCategory);
  }

  @override
  void didUpdateWidget(covariant CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      _updateCategoryFromWidget(widget.initialCategory);
    }
  }

  void _updateCategoryFromWidget(String? categoryValue) {
    if (categoryValue != null && categoryValue.contains(' > ')) {
      final parts = categoryValue.split(' > ');
      setState(() {
        _selectedMainCategory = parts[0];
        _selectedSubCategory = parts[1];
      });
    } else {
      setState(() {
        _selectedMainCategory = null;
        _selectedSubCategory = null;
      });
    }
  }

  void _selectMainCategory(String category) {
    setState(() {
      _selectedMainCategory = category;
      _selectedSubCategory = null;
    });
  }

  void _selectSubCategory(String subCategory) {
    setState(() {
      _selectedSubCategory = subCategory;
    });
    widget.onCategorySelected('$_selectedMainCategory > $_selectedSubCategory');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh mục *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                Expanded(
                  child: _buildSummaryView(),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.only(bottom: 16.0),
            width: double.infinity,
            child: _buildSelectionView(),
          ),
      ],
    );
  }

  Widget _buildSummaryView() {
    if (_selectedMainCategory == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Chưa chọn', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(width: 4),
          Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(child: Text(_selectedMainCategory!, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        if (_selectedSubCategory != null) ...[
          const Icon(Icons.arrow_right_alt_rounded, color: Colors.grey, size: 20),
          Flexible(child: Text(_selectedSubCategory!, style: TextStyle(fontSize: 16, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
        ],
        const SizedBox(width: 4),
        Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
      ],
    );
  }

  Widget _buildSelectionView() {
    if (_selectedMainCategory == null) {
      return Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: AppOptions.categories.keys.map((mainCategory) {
          return ActionChip(
            avatar: Icon(AppOptions.categoryIcons[mainCategory], size: 18),
            label: Text(mainCategory),
            onPressed: () => _selectMainCategory(mainCategory),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputChip(
          label: Text(_selectedMainCategory!),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          selected: true,
          onDeleted: () {
            setState(() {
              _selectedMainCategory = null;
              _selectedSubCategory = null;
            });
            widget.onCategorySelected('');
          },
          deleteIcon: const Icon(Icons.close, size: 18),
        ),
        const Divider(height: 16),
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