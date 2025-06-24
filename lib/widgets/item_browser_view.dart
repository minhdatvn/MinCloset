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

  const ItemBrowserView({
    super.key,
    required this.providerId,
    required this.onItemTapped,
    this.itemCounts = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemFilterProvider(providerId);
    final state = ref.watch(provider);

    if (state.isLoading && state.items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              state.searchQuery.isNotEmpty || state.activeFilters.isApplied
                  ? 'No items found.'
                  : 'Your closet is empty.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      sliver: SliverGrid.builder(
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (ctx, index) {
          if (index >= state.items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = state.items[index];
          final count = itemCounts[item.id] ?? 0;
          return GestureDetector(
            key: ValueKey('item_card_${item.id}'),
            onTap: () => onItemTapped(item),
            child: RecentItemCard(item: item, count: count),
          );
        },
      ),
    );
  }
}