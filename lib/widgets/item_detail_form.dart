// lib/widgets/item_detail_form.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class ItemDetailForm extends ConsumerWidget {
  final AddItemState itemState;
  final Function(String) onNameChanged;
  final Function(String?) onClosetChanged;
  final Function(String) onCategoryChanged;
  final Function(Set<String>) onColorsChanged;
  final Function(Set<String>) onSeasonsChanged;
  final Function(Set<String>) onOccasionsChanged;
  final Function(Set<String>) onMaterialsChanged;
  final Function(Set<String>) onPatternsChanged;
  final ScrollController? scrollController; // Thêm tham số này

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
    this.scrollController, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closetsAsync = ref.watch(closetsProvider);
    final nameController = TextEditingController(text: itemState.name);
    nameController.selection = TextSelection.fromPosition(TextPosition(offset: nameController.text.length));

    return SingleChildScrollView(
      controller: scrollController, // Gán controller vào đây
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // <<< BỌC ẢNH TRONG STACK ĐỂ HIỂN THỊ LOADING
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
                      child: itemState.image != null
                          ? Image.file(itemState.image!, fit: BoxFit.contain)
                          : (itemState.imagePath != null
                              ? Image.file(File(itemState.imagePath!), fit: BoxFit.contain)
                              : const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 60)),
                    ),
                  ),
                ),
              ),
              // Lớp phủ loading
              if (itemState.isAnalyzing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên món đồ *',
              border: OutlineInputBorder(),
            ),
            maxLength: 30,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 16),
          closetsAsync.when(
            data: (closets) {
              if (closets.isEmpty) return const SizedBox.shrink();
              return DropdownButtonFormField<String>(
                value: itemState.selectedClosetId,
                items: closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: onClosetChanged,
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
            initialCategory: itemState.selectedCategoryValue,
            onCategorySelected: onCategoryChanged,
          ),
          MultiSelectChipField(
            label: 'Màu sắc',
            allOptions: AppOptions.colors,
            initialSelections: itemState.selectedColors,
            onSelectionChanged: onColorsChanged,
          ),
          MultiSelectChipField(
            label: 'Mùa',
            allOptions: AppOptions.seasons,
            initialSelections: itemState.selectedSeasons,
            onSelectionChanged: onSeasonsChanged,
          ),
          MultiSelectChipField(
            label: 'Mục đích',
            allOptions: AppOptions.occasions,
            initialSelections: itemState.selectedOccasions,
            onSelectionChanged: onOccasionsChanged,
          ),
          MultiSelectChipField(
            label: 'Chất liệu',
            allOptions: AppOptions.materials,
            initialSelections: itemState.selectedMaterials,
            onSelectionChanged: onMaterialsChanged,
          ),
          MultiSelectChipField(
            label: 'Họa tiết',
            allOptions: AppOptions.patterns,
            initialSelections: itemState.selectedPatterns,
            onSelectionChanged: onPatternsChanged,
          ),
        ],
      ),
    );
  }
}