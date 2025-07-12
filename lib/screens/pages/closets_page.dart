// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/closet_form_dialog.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';

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

    return PageScaffold(
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
        physics: const NeverScrollableScrollPhysics(),
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

    return Scaffold(
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
      bottomNavigationBar: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      child: state.isMultiSelectMode
          ? BottomAppBar(
              key: const ValueKey('closets_page_bottom_bar'),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Các nút bấm giữ nguyên như cũ
                  _buildBottomBarButton(
                    context: context,
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: Colors.red,
                    onPressed: () async {
                      final confirmed = await showAnimatedDialog<bool>(
                        context,
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
                  ),
                  _buildBottomBarButton(
                    context: context,
                    icon: Icons.add_to_photos_outlined,
                    label: 'Create Outfit',
                    onPressed: () {
                      final selectedItems = state.items.where((item) => state.selectedItemIds.contains(item.id)).toList();
                      notifier.clearSelectionAndExitMode();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OutfitBuilderPage(preselectedItems: selectedItems)));
                    },
                  ),
                ],
              ),
            )
          // Khi không ở chế độ chọn nhiều, widget sẽ là một hộp rỗng
          : const SizedBox.shrink(key: ValueKey('empty_closets_page_bar')),
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
          crossAxisCount: 3,
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
          )
          // <<< BẮT ĐẦU THÊM HIỆU ỨNG >>>
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slide(
            begin: const Offset(0, 0.2), // Sửa .slideUp() thành .slide()
            duration: 400.ms,
            curve: Curves.easeOut,
            delay: (50 * (index % 15)).ms, // Thêm delay tăng dần cho hiệu ứng stagger
          );
        },
      ),
    );
  }
   Widget _buildBottomBarButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // Yêu cầu Column chỉ chiếm không gian tối thiểu theo chiều dọc
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              // Đặt chiều cao dòng chữ để nó gọn hơn
              height: 1.2,
            ),
          ),
        ],
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
class _ClosetsListTab extends ConsumerStatefulWidget {
  const _ClosetsListTab();

  @override
  ConsumerState<_ClosetsListTab> createState() => _ClosetsListTabState();
}

class _ClosetsListTabState extends ConsumerState<_ClosetsListTab> {
  @override
  Widget build(BuildContext context) {
    final closetsAsyncValue = ref.watch(closetsProvider);
    final theme = Theme.of(context);
    return closetsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (closets) {
        final isLimitReached = closets.length >= 10;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: closets.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) {
              // ... Mục "Add new closet" giữ nguyên, không có gì thay đổi
              if (isLimitReached) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Text(
                      'Closet limit (10) reached.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }
              return Card(
                elevation: 0,
                color: theme.colorScheme.primary.withValues(alpha:0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  title: Text('Add new closet', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  onTap: () {
                    showAnimatedDialog(
                      context,
                      builder: (ctx) => ClosetFormDialog(
                        onSubmit: (name) async {
                          final error = await ref.read(closetsPageProvider.notifier).addCloset(name);
                          if (error == null && context.mounted) {
                            ref.read(notificationServiceProvider).showBanner(
                                  message: 'Successfully created "$name" closet.',
                                  type: NotificationType.success,
                                );
                          }
                          return error;
                        },
                      ),
                    );
                  },
                ),
              );
            }
            final closet = closets[index - 1];
            // <<< BẮT ĐẦU TÁI CẤU TRÚC HOÀN TOÀN TỪ ĐÂY >>>
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Dismissible(
                  key: ValueKey(closet.id),
                  background: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.centerLeft,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final confirmed = await showAnimatedDialog<bool>(
                        context,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: Text('Are you sure you want to delete the "${closet.name}" closet?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('Cancel')),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => Navigator.of(dialogCtx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (!mounted || confirmed != true) return false;
                      final error = await ref.read(closetsPageProvider.notifier).deleteCloset(closet.id);
                      if (!mounted) return false;
                      if (error != null) {
                        ref.read(notificationServiceProvider).showBanner(message: error);
                        return false;
                      }
                      // <<< Banner khi xóa thành công >>>
                      ref.read(notificationServiceProvider).showBanner( 
                        message: 'Deleted closet "${closet.name}"',
                        type: NotificationType.success,
                      );
                      return true;
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => ClosetFormDialog(
                          initialName: closet.name,
                          onSubmit: (newName) async { // Thêm async ở đây
                            final error = await ref.read(closetsPageProvider.notifier).updateCloset(closet, newName);
                            // <<< Banner khi sửa thành công >>>
                            if (error == null && mounted) {
                              ref.read(notificationServiceProvider).showBanner(
                                    message: 'Closet name updated to "$newName"',
                                    type: NotificationType.success,
                                  );
                            }
                            return error;
                          },
                        ),
                      );
                      return false;
                    }
                  },
                  child: SizedBox(
                    height: 90,
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.closetDetail, arguments: closet),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              leading: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                // Icon tạm thời, sẵn sàng để thay bằng hình ảnh
                                child: const Icon(Icons.style_outlined, color: Colors.grey, size: 32),
                              ),
                            ),
                            // TIÊU ĐỀ: Tên closet
                            title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            // PHỤ ĐỀ: Số lượng item
                            subtitle: Consumer(
                              builder: (context, ref, child) {
                                // Lắng nghe provider để lấy số lượng item
                                final itemsCountAsync = ref.watch(itemsInClosetProvider(closet.id));
                                return itemsCountAsync.when(
                                  data: (items) {
                                    // Định dạng số nhiều/ít cho "item"
                                    final itemText = items.length == 1 ? 'item' : 'items';
                                    return Text('${items.length} $itemText');
                                  },
                                  // Hiển thị tạm thời trong khi tải
                                  loading: () => const Text('...'),
                                  error: (err, stack) => const Text('Error'),
                                );
                              },
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ),
                    ),
                  ),
                ),
              ),
              )
            );
          },
        );
      },
    );
  }
}