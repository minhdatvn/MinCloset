// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/providers/service_providers.dart';

// Hàm _showAddClosetDialog không thay đổi
void _showAddClosetDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  String? errorText;

  showDialog(
    context: context,
    // barrierDismissible: false, // Không cho phép đóng khi nhấn ra ngoài
    builder: (ctx) {
      // Dùng StatefulBuilder để dialog có thể tự cập nhật trạng thái
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Create new closet'),
            content: TextField(
              controller: nameController,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: 'Closet name',
                // Hiển thị lỗi ngay trên TextField
                errorText: errorText,
              ),
              // Xóa lỗi khi người dùng bắt đầu nhập lại
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() {
                    errorText = null;
                  });
                }
              },
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  // Lấy ra Navigator TRƯỚC khi gọi await
                  final navigator = Navigator.of(ctx);
                  final notifier = ref.read(closetsPageProvider.notifier);
                  final notificationService = ref.read(notificationServiceProvider);

                  final error = await notifier.addCloset(nameController.text);

                  if (error == null) {
                    // <<< THAY ĐỔI CỐT LÕI NẰM Ở ĐÂY >>>
                    // Thành công, đóng dialog và hiển thị thông báo
                    navigator.pop();
                    notificationService.showBanner(
                      message: 'Successfully created "${nameController.text}" closet.',
                      type: NotificationType.success,
                    );
                  } else {
                    // Thất bại, cập nhật state của dialog để hiển thị lỗi
                    setDialogState(() {
                      errorText = error;
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showEditClosetDialog(
    BuildContext context, WidgetRef ref, Closet closetToEdit) {
  final nameController = TextEditingController(text: closetToEdit.name);
  String? errorText;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Edit closet name'),
            content: TextField(
              controller: nameController,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: 'New name',
                errorText: errorText,
              ),
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() {
                    errorText = null;
                  });
                }
              },
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final notifier = ref.read(closetsPageProvider.notifier);
                  final error = await notifier.updateCloset(
                      closetToEdit, nameController.text);

                  if (error == null) {
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } else {
                    setDialogState(() {
                      errorText = error;
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
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
                height: 60, // Đặt chiều cao
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Nút Xóa
                    _buildBottomBarButton(
                      context: context,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: Colors.red,
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
                    ),
                    // Nút Tạo trang phục
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
          padding: const EdgeInsets.only(top: 8),
          itemCount: closets.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) {
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
              return ListTile(
                leading: Icon(Icons.add_circle_outline,
                    color: theme.colorScheme.primary),
                title: Text('Add new closet',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                onTap: () => _showAddClosetDialog(context, ref),
              );
            }
            final closet = closets[index - 1];
            return Dismissible(
              key: ValueKey(closet.id),
              // Nền cho thao tác vuốt trái (xóa)
              background: Container(
                color: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              // Nền cho thao tác vuốt phải (sửa)
              secondaryBackground: Container(
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {

                // Xử lý khi vuốt sang trái để XÓA
                if (direction == DismissDirection.endToStart) {
                  final confirmed = await showDialog<bool>(
                    context: context, // An toàn khi dùng context ở đây vì chưa có await
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text(
                          'Are you sure you want to delete the "${closet.name}" closet?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          onPressed: () => Navigator.of(dialogCtx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  // Kiểm tra mounted sau await đầu tiên, và kiểm tra người dùng có xác nhận không
                  if (!mounted || confirmed != true) {
                    return false;
                  }

                  final error = await ref
                      .read(closetsPageProvider.notifier)
                      .deleteCloset(closet.id);

                  // Kiểm tra mounted lần nữa sau await thứ hai
                  if (!mounted) return false;

                  if (error != null) {
                    // --- BƯỚC 2: Sử dụng các biến đã lưu ở trên, không dùng context trực tiếp ---
                    ref.read(notificationServiceProvider).showBanner(
                          message: error,
                          // type mặc định là error nên không cần truyền
                        );
                    return false; // Hủy thao tác xóa
                  }
                  return true; // Cho phép xóa
                }
                // Xử lý khi vuốt sang phải để SỬA
                else {
                  // Vẫn an toàn vì _showEditClosetDialog không phải là async ở đây
                  _showEditClosetDialog(context, ref, closet);
                  // Luôn trả về false để item không bị "biến mất" sau khi vuốt
                  return false;
                }
              },
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(closet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.closetDetail,
                    arguments: closet),
              ),
            );
          },
        );
      },
    );
  }
}