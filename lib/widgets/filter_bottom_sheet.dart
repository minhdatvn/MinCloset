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
  // <<< THÊM THAM SỐ HÀM CALLBACK NÀY
  final void Function(OutfitFilter) onApplyFilter;
  
  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.closets,
    required this.onApplyFilter, // Yêu cầu phải có
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bộ lọc', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Xóa bộ lọc bằng cách áp dụng một bộ lọc rỗng
                    widget.onApplyFilter(const OutfitFilter());
                    Navigator.of(context).pop();
                  },
                  child: const Text('Xóa bộ lọc'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  // <<< SỬA LẠI HÀM NÀY
                  onPressed: () {
                    // Gọi hàm callback và truyền bộ lọc tạm thời về
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
    );
  }
}