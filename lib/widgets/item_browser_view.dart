// lib/widgets/item_browser_view.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/states/item_filter_state.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

class ItemBrowserView extends ConsumerWidget {
  final String providerId;
  final void Function(ClothingItem) onItemTapped;
  final ScrollController? scrollController;

  const ItemBrowserView({
    super.key,
    required this.providerId,
    required this.onItemTapped,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemFilterProvider(providerId);
    final state = ref.watch(provider);
    
    // <<< XÓA CÁC BIẾN `notifier` và `closetsAsync` KHÔNG DÙNG ĐẾN

    // Hàm build giờ chỉ trả về GridView
    return _buildItemsGrid(context, state, onItemTapped, scrollController);
  }

  Widget _buildItemsGrid(BuildContext context, ItemFilterState state, void Function(ClothingItem) onItemTapped, ScrollController? scrollController) {
    if (state.isLoading && state.filteredItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.filteredItems.isEmpty) {
      if (state.searchQuery.isNotEmpty || state.activeFilters.isApplied) {
        return const Center(child: Text('Không tìm thấy vật phẩm nào.'));
      }
      return const Center(child: Text('Tủ đồ của bạn chưa có vật phẩm nào.'));
    }

    return GridView.builder(
      controller: scrollController,
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
        return GestureDetector(
          onTap: () => onItemTapped(item),
          child: RecentItemCard(item: item),
        );
      },
    );
  }
}