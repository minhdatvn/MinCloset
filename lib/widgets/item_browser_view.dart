// lib/widgets/item_browser_view.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

enum ItemBrowserBuildMode { box, sliver }

class ItemBrowserView extends ConsumerWidget {
  final String providerId;
  final void Function(ClothingItem) onItemTapped;
  final Map<String, int> itemCounts;
  final ItemBrowserBuildMode buildMode;

  const ItemBrowserView({
    super.key,
    required this.providerId,
    required this.onItemTapped,
    this.itemCounts = const {},
    this.buildMode = ItemBrowserBuildMode.box,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemFilterProvider(providerId);
    final state = ref.watch(provider);

    if (state.isLoading && state.filteredItems.isEmpty) {
      final loadingWidget = const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
      return buildMode == ItemBrowserBuildMode.sliver
          ? SliverToBoxAdapter(child: loadingWidget)
          : loadingWidget;
    }

    if (state.filteredItems.isEmpty) {
      final emptyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            state.searchQuery.isNotEmpty || state.activeFilters.isApplied
                ? 'Không tìm thấy vật phẩm nào.'
                : 'Tủ đồ của bạn chưa có vật phẩm nào.',
          ),
        ),
      );
      return buildMode == ItemBrowserBuildMode.sliver
          ? SliverToBoxAdapter(child: emptyWidget)
          : emptyWidget;
    }

    if (buildMode == ItemBrowserBuildMode.sliver) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        sliver: SliverGrid.builder(
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
              // <<< THAY ĐỔI Ở ĐÂY
              key: ValueKey('item_card_${item.id}'),
              onTap: () => onItemTapped(item),
              child: RecentItemCard(item: item, count: count),
            );
          },
        ),
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            // <<< VÀ THAY ĐỔI Ở ĐÂY
            key: ValueKey('item_card_${item.id}'),
            onTap: () => onItemTapped(item),
            child: RecentItemCard(item: item, count: count),
          );
        },
      );
    }
  }
}