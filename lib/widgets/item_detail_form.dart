// lib/widgets/item_detail_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

// <<< CHUYỂN THÀNH `ConsumerStatefulWidget` >>>
class ItemDetailForm extends ConsumerStatefulWidget {
  final AddItemState itemState;
  final Function(String) onNameChanged;
  final Function(String?) onClosetChanged;
  final Function(String) onCategoryChanged;
  final Function(Set<String>) onColorsChanged;
  final Function(Set<String>) onSeasonsChanged;
  final Function(Set<String>) onOccasionsChanged;
  final Function(Set<String>) onMaterialsChanged;
  final Function(Set<String>) onPatternsChanged;
  final ScrollController? scrollController;

  const ItemDetailForm({
    super.key,
    required this.itemState,
    required this.onNameChanged,
    required this.onClosetChanged,
    required this.onCategoryChanged,
    required this.onColorsChanged,
    required this.onSeasonsChanged,
    required this.onOccasionsChanged,
    required this.onMaterialsChanged,
    required this.onPatternsChanged,
    this.scrollController,
  });

  @override
  ConsumerState<ItemDetailForm> createState() => _ItemDetailFormState();
}

class _ItemDetailFormState extends ConsumerState<ItemDetailForm> {
  // <<< QUẢN LÝ `TextEditingController` TRONG STATE >>>
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemState.name);
  }

  @override
  void didUpdateWidget(covariant ItemDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật text trong controller nếu state từ notifier thay đổi
    if (widget.itemState.name != oldWidget.itemState.name) {
      _nameController.text = widget.itemState.name;
      // Di chuyển con trỏ về cuối
      _nameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _nameController.text.length));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closetsAsync = ref.watch(closetsProvider);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: widget.itemState.image != null
                          ? Image.file(widget.itemState.image!, fit: BoxFit.contain)
                          : (widget.itemState.imagePath != null
                              ? Image.file(File(widget.itemState.imagePath!), fit: BoxFit.contain)
                              : const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 60)),
                    ),
                  ),
                ),
              ),
              if (widget.itemState.isAnalyzing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // <<< SỬ DỤNG CONTROLLER TỪ STATE >>>
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên món đồ *',
              border: OutlineInputBorder(),
            ),
            maxLength: 30,
            onChanged: widget.onNameChanged,
          ),
          const SizedBox(height: 16),
          closetsAsync.when(
            data: (closets) {
              if (closets.isEmpty) return const SizedBox.shrink();
              return DropdownButtonFormField<String>(
                value: widget.itemState.selectedClosetId,
                items: closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: widget.onClosetChanged,
                decoration: const InputDecoration(
                  labelText: 'Chọn tủ đồ *',
                  border: OutlineInputBorder(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Lỗi tải tủ đồ: $err'),
          ),
          const SizedBox(height: 16),
          CategorySelector(
            initialCategory: widget.itemState.selectedCategoryValue,
            onCategorySelected: widget.onCategoryChanged,
          ),
          MultiSelectChipField(
            label: 'Màu sắc',
            allOptions: AppOptions.colors,
            initialSelections: widget.itemState.selectedColors,
            onSelectionChanged: widget.onColorsChanged,
          ),
          MultiSelectChipField(
            label: 'Mùa',
            allOptions: AppOptions.seasons,
            initialSelections: widget.itemState.selectedSeasons,
            onSelectionChanged: widget.onSeasonsChanged,
          ),
          MultiSelectChipField(
            label: 'Mục đích',
            allOptions: AppOptions.occasions,
            initialSelections: widget.itemState.selectedOccasions,
            onSelectionChanged: widget.onOccasionsChanged,
          ),
          MultiSelectChipField(
            label: 'Chất liệu',
            allOptions: AppOptions.materials,
            initialSelections: widget.itemState.selectedMaterials,
            onSelectionChanged: widget.onMaterialsChanged,
          ),
          MultiSelectChipField(
            label: 'Họa tiết',
            allOptions: AppOptions.patterns,
            initialSelections: widget.itemState.selectedPatterns,
            onSelectionChanged: widget.onPatternsChanged,
          ),
        ],
      ),
    );
  }
}