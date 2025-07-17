// lib/widgets/item_search_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/widgets/filter_bottom_sheet.dart';

class ItemSearchFilterBar extends HookConsumerWidget {
  final String providerId;
  final void Function(OutfitFilter)? onApplyFilter;
  final bool showClosetFilter;
  final OutfitFilter activeFilters;

  const ItemSearchFilterBar({
    super.key,
    required this.providerId,
    this.onApplyFilter,
    this.showClosetFilter = true,
    this.activeFilters = const OutfitFilter(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng Hook để quản lý controller một cách gọn gàng
    final searchController = useTextEditingController();
    // Lấy state và notifier tương ứng với providerId được truyền vào
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    final closetsAsync = ref.watch(closetsProvider);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: l10n.allItems_searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.zero, // Điều chỉnh padding cho gọn
              ),
              onChanged: notifier.setSearchQuery,
            ),
          ),
          const SizedBox(width: 8),
          if (onApplyFilter != null)
            IconButton(
              icon: Badge(
                isLabelVisible: activeFilters.isApplied,
                child: const Icon(Icons.filter_list),
              ),
              tooltip: l10n.allItems_filterTooltip,
              onPressed: () {
                closetsAsync.whenData((closets) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FilterBottomSheet(
                      currentFilter: activeFilters,
                      closets: closets,
                      // Gọi đến callback onApplyFilter đã được truyền vào
                      onApplyFilter: onApplyFilter!,
                      // Truyền giá trị showClosetFilter vào BottomSheet
                      showClosetFilter: showClosetFilter,
                    ),
                  );
                });
              },
            ),
        ],
      ),
    );
  }
}