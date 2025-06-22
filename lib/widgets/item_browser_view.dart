// lib/widgets/item_browser_view.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

class ItemBrowserView extends ConsumerWidget {
  final String providerId;
  final void Function(ClothingItem) onItemTapped;
  final Map<String, int> itemCounts;
  final ScrollController? scrollController;

  const ItemBrowserView({
    super.key,
    required this.providerId,
    required this.onItemTapped,
    this.itemCounts = const {},
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemFilterProvider(providerId);
    final state = ref.watch(provider);

    if (state.isLoading && state.filteredItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            state.searchQuery.isNotEmpty || state.activeFilters.isApplied
                ? 'Không tìm thấy vật phẩm nào.'
                : 'Tủ đồ của bạn chưa có vật phẩm nào.',
          ),
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.filteredItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (ctx, index) {
        final item = state.filteredItems[index];
        final count = itemCounts[item.id] ?? 0;
        return GestureDetector(
          key: ValueKey('item_card_${item.id}'),
          onTap: () => onItemTapped(item),
          child: RecentItemCard(item: item, count: count),
        );
      },
    );
  }
}