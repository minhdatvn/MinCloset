// lib/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

// Dùng ConsumerStatefulWidget để quản lý các lựa chọn tạm thời trong bottom sheet
class FilterBottomSheet extends ConsumerStatefulWidget {
  final OutfitFilter currentFilter;
  final List<Closet> closets;

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.closets,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late OutfitFilter _temporaryFilter;

  @override
  void initState() {
    super.initState();
    // Sao chép bộ lọc hiện tại vào một biến tạm để người dùng thay đổi
    _temporaryFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bộ lọc', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          // Lọc theo tủ đồ
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
          // Lọc theo màu sắc
          MultiSelectChipField(
            label: 'Màu sắc',
            allOptions: AppOptions.colors,
            initialSelections: _temporaryFilter.colors,
            onSelectionChanged: (newColors) {
               setState(() {
                 _temporaryFilter = _temporaryFilter.copyWith(colors: newColors);
               });
            },
          ),
          const SizedBox(height: 24),
          // Các nút hành động
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(outfitBuilderProvider.notifier).clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Xóa bộ lọc'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Áp dụng bộ lọc tạm thời vào state chính
                    ref.read(outfitBuilderProvider.notifier).applyFilters(_temporaryFilter);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}