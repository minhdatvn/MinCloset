// lib/widgets/item_search_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/widgets/filter_bottom_sheet.dart';

class ItemSearchFilterBar extends HookConsumerWidget {
  final String providerId;

  const ItemSearchFilterBar({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng Hook để quản lý controller một cách gọn gàng
    final searchController = useTextEditingController();
    // Lấy state và notifier tương ứng với providerId được truyền vào
    final state = ref.watch(itemFilterProvider(providerId));
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    final closetsAsync = ref.watch(closetsProvider);

    // Đồng bộ text trong controller với state (hữu ích khi xóa filter)
    useEffect(() {
      if (searchController.text != state.searchQuery) {
        searchController.text = state.searchQuery;
      }
      return null;
    }, [state.searchQuery]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
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
          IconButton(
            icon: Badge(
              // Hiển thị badge nếu có filter đang được áp dụng
              isLabelVisible: state.activeFilters.isApplied,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter',
            onPressed: () {
              // Chỉ mở bottom sheet khi đã tải xong danh sách tủ đồ
              closetsAsync.whenData((closets) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => FilterBottomSheet(
                    currentFilter: state.activeFilters,
                    closets: closets,
                    onApplyFilter: notifier.applyFilters,
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