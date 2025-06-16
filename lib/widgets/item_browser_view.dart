// lib/widgets/item_browser_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/widgets/filter_bottom_sheet.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

class ItemBrowserView extends HookConsumerWidget {
  final String providerId;
  final void Function(ClothingItem) onItemTapped;

  const ItemBrowserView({
    super.key,
    required this.providerId,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = itemFilterProvider(providerId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    final searchController = useTextEditingController();
    final closetsAsync = ref.watch(closetsProvider);

    // Cập nhật search bar nếu query trong state thay đổi (ví dụ khi xóa filter)
    useEffect(() {
      if (searchController.text != state.searchQuery) {
        searchController.text = state.searchQuery;
      }
      return null;
    }, [state.searchQuery]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm vật phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: notifier.setSearchQuery,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Badge(
                  isLabelVisible: state.activeFilters.isApplied,
                  child: const Icon(Icons.filter_list),
                ),
                tooltip: 'Lọc nâng cao',
                onPressed: () {
                  closetsAsync.whenData((closets) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FilterBottomSheet(
                        currentFilter: state.activeFilters,
                        closets: closets,
                        // <<< LỖI ĐƯỢC SỬA TẠI ĐÂY
                        // Đổi tên `applyAdvancedFilters` thành `applyFilters` cho đúng
                        onApplyFilter: notifier.applyFilters, 
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildItemsGrid(state.filteredItems, state.isLoading, state.searchQuery, onItemTapped),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(List<ClothingItem> items, bool isLoading, String searchQuery, void Function(ClothingItem) onItemTapped) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      if (searchQuery.isNotEmpty || isLoading) { // Thêm điều kiện isLoading
        return const Center(child: Text('Không tìm thấy vật phẩm nào.'));
      }
      return const Center(child: Text('Tủ đồ của bạn chưa có vật phẩm nào.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (ctx, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onItemTapped(item),
          child: RecentItemCard(item: item),
        );
      },
    );
  }
}