// lib/widgets/category_selector.dart

import 'package:flutter/material.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/l10n_helper.dart';

class CategorySelector extends StatefulWidget {
  final String? initialCategory;
  final Function(String) onCategorySelected;
  final Widget? labelAction;

  const CategorySelector({
    super.key,
    this.initialCategory,
    required this.onCategorySelected,
    this.labelAction,
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
    if (categoryValue != null && categoryValue.isNotEmpty) {
      if (categoryValue.contains(' > ')) {
        final parts = categoryValue.split(' > ');
        setState(() {
          _selectedMainCategory = parts[0];
          _selectedSubCategory = parts[1];
        });
      } else {
        // Trường hợp chỉ có 1 cấp (chính là 'Other')
        setState(() {
          _selectedMainCategory = categoryValue;
          _selectedSubCategory = null; // Không có danh mục con
        });
      }
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

      if (category == 'category_other' || (AppOptions.categories[category]?.isEmpty ?? true)) {
        widget.onCategorySelected(category);
      }
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
    final l10n = context.l10n;
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( // Bọc Text và labelAction trong một Row con
                  children: [
                    Text(l10n.itemDetail_form_categoryLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
                    if (widget.labelAction != null) ...[
                      const SizedBox(width: 4),
                      widget.labelAction!,
                    ],
                  ],
                ),
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
    final l10n = context.l10n;
    if (_selectedMainCategory == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(l10n.itemDetail_form_categoryNoneSelected, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(width: 4),
          Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(child: Text(translateAppOption(_selectedMainCategory!, l10n), style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        if (_selectedSubCategory != null) ...[
          const Icon(Icons.arrow_right_alt_rounded, color: Colors.grey, size: 20),
          Flexible(child: Text(translateAppOption(_selectedSubCategory!, l10n), style: TextStyle(fontSize: 16, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
        ],
        const SizedBox(width: 4),
        Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey),
      ],
    );
  }

  Widget _buildSelectionView() {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (_selectedMainCategory == null) {
      // Giao diện chọn danh mục chính
      return Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: AppOptions.categories.keys.map((mainCategoryKey) {
          return ActionChip(
            avatar: Icon(AppOptions.categoryIcons[mainCategoryKey], size: 18), // Icon vẫn dùng key cũ
            label: Text(translateAppOption(mainCategoryKey, l10n)),
            onPressed: () => _selectMainCategory(mainCategoryKey),
            backgroundColor: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(color: theme.colorScheme.onSurface, width: 1),
            ),
          );
        }).toList(),
      );
    }

    final subCategoryKeys = AppOptions.categories[_selectedMainCategory] ?? [];
    // Giao diện chọn danh mục con
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: Text(translateAppOption(_selectedMainCategory!, l10n)),
          labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: theme.colorScheme.primary,
          deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
          onDeleted: () {
            setState(() {
              _selectedMainCategory = null;
              _selectedSubCategory = null;
            });
            widget.onCategorySelected('');
          },
        ),
        const Divider(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          // Sử dụng danh sách đã được lấy một cách an toàn
          children: subCategoryKeys.map((subCategoryKey) {
            final isSelected = _selectedSubCategory == subCategoryKey;
            return FilterChip(
              label: Text(
                translateAppOption(subCategoryKey, l10n),
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _selectSubCategory(subCategoryKey);
                }
              },
              showCheckmark: false,
              backgroundColor: Colors.white,
              selectedColor: theme.colorScheme.primary,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}