// lib/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final OutfitFilter currentFilter;
  final List<Closet> closets;
  final void Function(OutfitFilter) onApplyFilter;
  
  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.closets,
    required this.onApplyFilter,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late OutfitFilter _temporaryFilter;

  @override
  void initState() {
    super.initState();
    _temporaryFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    // <<< THAY ĐỔI 1: Bọc toàn bộ widget trong Container để có nền trắng và góc bo
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Dùng màu nền của card theme
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // <<< THAY ĐỔI 2: Dùng SingleChildScrollView để tránh lỗi tràn màn hình
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Bộ lọc', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 16),

              // BỘ LỌC TỦ ĐỒ (GIỮ NGUYÊN)
              DropdownButtonFormField<String?>(
                value: _temporaryFilter.closetId,
                decoration: const InputDecoration(labelText: 'Tủ đồ'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tất cả tủ đồ')),
                  ...widget.closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (value) {
                  setState(() {
                    _temporaryFilter = _temporaryFilter.copyWith(closetId: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // <<< THÊM MỚI: BỘ LỌC DANH MỤC
              DropdownButtonFormField<String?>(
                value: _temporaryFilter.category,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tất cả danh mục')),
                  ...AppOptions.categories.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (value) {
                  setState(() {
                    _temporaryFilter = _temporaryFilter.copyWith(category: value);
                  });
                },
              ),
              const Divider(height: 32),

              // CÁC BỘ LỌC CHỌN NHIỀU
              MultiSelectChipField(
                label: 'Màu sắc',
                allOptions: AppOptions.colors,
                initialSelections: _temporaryFilter.colors,
                onSelectionChanged: (newSelections) {
                    setState(() {
                      _temporaryFilter = _temporaryFilter.copyWith(colors: newSelections);
                    });
                },
              ),
              MultiSelectChipField(
                label: 'Mùa',
                allOptions: AppOptions.seasons,
                initialSelections: _temporaryFilter.seasons,
                onSelectionChanged: (newSelections) {
                    setState(() {
                      _temporaryFilter = _temporaryFilter.copyWith(seasons: newSelections);
                    });
                },
              ),
              MultiSelectChipField(
                label: 'Mục đích',
                allOptions: AppOptions.occasions,
                initialSelections: _temporaryFilter.occasions,
                onSelectionChanged: (newSelections) {
                    setState(() {
                      _temporaryFilter = _temporaryFilter.copyWith(occasions: newSelections);
                    });
                },
              ),
              MultiSelectChipField(
                label: 'Chất liệu',
                allOptions: AppOptions.materials,
                initialSelections: _temporaryFilter.materials,
                onSelectionChanged: (newSelections) {
                    setState(() {
                      _temporaryFilter = _temporaryFilter.copyWith(materials: newSelections);
                    });
                },
              ),
              MultiSelectChipField(
                label: 'Họa tiết',
                allOptions: AppOptions.patterns,
                initialSelections: _temporaryFilter.patterns,
                onSelectionChanged: (newSelections) {
                    setState(() {
                      _temporaryFilter = _temporaryFilter.copyWith(patterns: newSelections);
                    });
                },
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onApplyFilter(const OutfitFilter());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Xóa bộ lọc'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilter(_temporaryFilter);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}