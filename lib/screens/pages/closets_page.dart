// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

// Hàm _showAddClosetDialog không thay đổi
void _showAddClosetDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Create New Closet'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Closet name'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final closetName = nameController.text.trim();
            if (closetName.isNotEmpty) {
              // Gọi notifier để lưu nhưng không cần 'await'
              ref.read(closetsPageProvider.notifier).addCloset(closetName);
              // Đóng hộp thoại ngay lập tức
              Navigator.of(ctx).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class ClosetsPage extends ConsumerStatefulWidget {
  const ClosetsPage({super.key});
  @override
  ConsumerState<ClosetsPage> createState() => _ClosetsPageState();
}

class _ClosetsPageState extends ConsumerState<ClosetsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const allItemsProviderId = 'closetsPage';
    final allItemsState = ref.watch(itemFilterProvider(allItemsProviderId));  

    return Scaffold(
      appBar: AppBar(
        // Tự động tắt nút back khi ở chế độ chọn nhiều
        automaticallyImplyLeading: !allItemsState.isMultiSelectMode,
        // Hiển thị nút 'X' để thoát khi ở chế độ chọn nhiều
        leading: allItemsState.isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(itemFilterProvider(allItemsProviderId).notifier).clearSelectionAndExitMode(),
              )
            : null,
        // Thay đổi tiêu đề một cách linh động
        title: Text(
          allItemsState.isMultiSelectMode
              ? '${allItemsState.selectedItemIds.length} selected'
              : 'Your Closet',
        ),
        // Giữ nguyên TabBar, nhưng ẩn nó đi khi đang chọn nhiều
        bottom: allItemsState.isMultiSelectMode
            ? null // Ẩn TabBar
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Items'),
                  Tab(text: 'By Closet'),
                ],
              ),
      ),
      body: TabBarView(
        // Khóa việc vuốt chuyển tab khi đang chọn nhiều để tránh lỗi
        physics: allItemsState.isMultiSelectMode
            ? const NeverScrollableScrollPhysics()
            : null,
        controller: _tabController,
        children: const [
          _AllItemsTab(),
          _ClosetsListTab(),
        ],
      ),
    );
  }
}

// <<< SỬA LẠI HOÀN TOÀN TAB NÀY ĐỂ HỖ TRỢ MULTI-SELECT >>>
class _AllItemsTab extends ConsumerStatefulWidget {
  const _AllItemsTab();
  @override
  ConsumerState<_AllItemsTab> createState() => _AllItemsTabState();
}

class _AllItemsTabState extends ConsumerState<_AllItemsTab> {
  final ScrollController _scrollController = ScrollController();
  static const providerId = 'closetsPage'; // ID cho provider của tab này

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    final state = ref.read(itemFilterProvider(providerId));
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !state.isLoadingMore &&
        !state.isMultiSelectMode && // Không tải thêm khi đang chọn nhiều
        state.hasMore) {
      notifier.fetchMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = itemFilterProvider(providerId);
    final notifier = ref.read(provider.notifier);
    final state = ref.watch(provider);

    return PopScope(
      canPop: !state.isMultiSelectMode,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (state.isMultiSelectMode) {
          notifier.clearSelectionAndExitMode();
        }
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: notifier.fetchInitialItems,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  ItemSearchFilterBar(providerId: providerId),
                ),
              ),
              // Xử lý các trạng thái loading/empty/error
              if (state.isLoading && state.items.isEmpty)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state.errorMessage != null && state.items.isEmpty)
                SliverFillRemaining(child: Center(child: Text(state.errorMessage!)))
              else if (state.items.isEmpty)
                 SliverFillRemaining(
                    child: Center(
                      child: Text(
                        state.searchQuery.isNotEmpty || state.activeFilters.isApplied ? 'No items found.' : 'Your closet is empty.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  )
              else
                _buildItemsGrid(state.items, state.hasMore, state.isMultiSelectMode),
            ],
          ),
        ),
        bottomNavigationBar: state.isMultiSelectMode
            ? BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text('Are you sure you want to permanently delete ${state.selectedItemIds.length} selected item(s)?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await notifier.deleteSelectedItems();
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_to_photos_outlined),
                      label: const Text('Create Outfit'),
                      onPressed: () {
                        final selectedItems = state.items.where((item) => state.selectedItemIds.contains(item.id)).toList();
                        notifier.clearSelectionAndExitMode();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => OutfitBuilderPage(preselectedItems: selectedItems)));
                      },
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildItemsGrid(List<ClothingItem> items, bool hasMore, bool isMultiSelectMode) {
    final provider = itemFilterProvider(providerId);
    final notifier = ref.read(provider.notifier);
    final state = ref.watch(provider);
    
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid.builder(
        itemCount: items.length + (hasMore && !isMultiSelectMode ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (ctx, index) {
          if (index >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = items[index];
          final isSelected = state.selectedItemIds.contains(item.id);

          return GestureDetector(
            onLongPress: () {
              if (!isMultiSelectMode) {
                notifier.enableMultiSelectMode(item.id);
              }
            },
            onTap: () async {
              if (isMultiSelectMode) {
                notifier.toggleItemSelection(item.id);
              } else {
                final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemNotifierArgs(tempId: item.id, itemToEdit: item));
                if (wasChanged == true) {
                  ref.read(itemChangedTriggerProvider.notifier).state++;
                }
              }
            },
            child: RecentItemCard(item: item, isSelected: isSelected),
          );
        },
      ),
    );
  }
}

// <<< THÊM MỚI: Lớp Delegate cho SliverPersistentHeader >>>
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final ItemSearchFilterBar _searchBar;

  _SliverAppBarDelegate(this._searchBar);

  @override
  double get minExtent => 72.0; // Chiều cao tối thiểu khi cuộn

  @override
  double get maxExtent => 72.0; // Chiều cao tối đa khi mở rộng

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Thêm màu nền để không bị trong suốt
      child: _searchBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}


// _ClosetsListTab không thay đổi
class _ClosetsListTab extends ConsumerWidget {
  const _ClosetsListTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closetsAsyncValue = ref.watch(closetsProvider);
    final theme = Theme.of(context);
    return closetsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (closets) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: closets.length + 1,
          itemBuilder: (ctx, index) {
            if (index == closets.length) {
              return ListTile(
                leading: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                title: Text('Add New Closet', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                onTap: () => _showAddClosetDialog(context, ref),
              );
            }
            final closet = closets[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, AppRoutes.closetDetail, arguments: closet),
            );
          },
        );
      },
    );
  }
}