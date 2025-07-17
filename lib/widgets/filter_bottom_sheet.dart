// lib/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/l10n_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final OutfitFilter currentFilter;
  final List<Closet> closets;
  final void Function(OutfitFilter) onApplyFilter;
  final bool showClosetFilter;
  
  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.closets,
    required this.onApplyFilter,
    this.showClosetFilter = true,
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
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Dùng màu nền của card theme
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // <<< THAY ĐỔI 2: Dùng SingleChildScrollView để tránh lỗi tràn màn hình
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.filter_title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 16),

                // BỘ LỌC TỦ ĐỒ
                if (widget.showClosetFilter) ...[
                  DropdownButtonFormField<String?>(
                    value: _temporaryFilter.closetId,
                    decoration: InputDecoration(labelText: l10n.filter_closet),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.filter_allClosets)),
                      ...widget.closets.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _temporaryFilter = _temporaryFilter.copyWith(closetId: value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // BỘ LỌC DANH MỤC
                DropdownButtonFormField<String?>(
                  value: _temporaryFilter.category,
                  decoration: InputDecoration(labelText: l10n.filter_category),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.filter_allCategories)),
                    ...AppOptions.categories.keys.map((c) => DropdownMenuItem(value: c, child: Text(translateAppOption(c, l10n)))),
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
                  label: l10n.filter_color,
                  allOptions: AppOptions.colors,
                  initialSelections: _temporaryFilter.colors,
                  onSelectionChanged: (newSelections) {
                      setState(() {
                        _temporaryFilter = _temporaryFilter.copyWith(colors: newSelections);
                      });
                  },
                ),
                MultiSelectChipField(
                  label: l10n.filter_season,
                  allOptions: AppOptions.seasons,
                  initialSelections: _temporaryFilter.seasons,
                  onSelectionChanged: (newSelections) {
                      setState(() {
                        _temporaryFilter = _temporaryFilter.copyWith(seasons: newSelections);
                      });
                  },
                ),
                MultiSelectChipField(
                  label: l10n.filter_occasion,
                  allOptions: AppOptions.occasions,
                  initialSelections: _temporaryFilter.occasions,
                  onSelectionChanged: (newSelections) {
                      setState(() {
                        _temporaryFilter = _temporaryFilter.copyWith(occasions: newSelections);
                      });
                  },
                ),
                MultiSelectChipField(
                  label: l10n.filter_material,
                  allOptions: AppOptions.materials,
                  initialSelections: _temporaryFilter.materials,
                  onSelectionChanged: (newSelections) {
                      setState(() {
                        _temporaryFilter = _temporaryFilter.copyWith(materials: newSelections);
                      });
                  },
                ),
                MultiSelectChipField(
                  label: l10n.filter_pattern,
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
                        child: Text(l10n.filter_clear),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilter(_temporaryFilter);
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.filter_apply),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}