// lib/screens/pages/closet_detail_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/closet_detail_notifier.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
import 'package:mincloset/widgets/multi_select_action_button.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:mincloset/widgets/persistent_header_delegate.dart';

class ClosetDetailPage extends ConsumerStatefulWidget {
  final Closet closet;
  const ClosetDetailPage({super.key, required this.closet});

  @override
  ConsumerState<ClosetDetailPage> createState() => _ClosetDetailPageState();
}

class _ClosetDetailPageState extends ConsumerState<ClosetDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final notifier = ref.read(closetDetailProvider(widget.closet.id).notifier);
    final state = ref.read(closetDetailProvider(widget.closet.id));

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoadingMore &&
        !state.hasMore &&
        !state.isMultiSelectMode) { // Không tải thêm khi đang ở chế độ chọn nhiều
      notifier.fetchMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showMoveDialog(ClosetDetailNotifier notifier, Set<ClothingItem> itemsToMove) async {
    final l10n = context.l10n;
    final closets = await ref.read(closetsProvider.future);
    final availableClosets = closets.where((c) => c.id != widget.closet.id).toList();

    if (!mounted) return;
    if (availableClosets.isEmpty) {
        ref.read(notificationServiceProvider).showBanner(
          message: l10n.closetDetail_moveErrorNoClosets,
          type: NotificationType.warning,
        );
      return;
    }

    final String? targetClosetId = await showAnimatedDialog(
      context,
      builder: (ctx) => _MoveItemsDialog(
        availableClosets: availableClosets,
        itemCount: itemsToMove.length,
      ),
    );

    if (targetClosetId != null) {
      await notifier.moveSelectedItems(targetClosetId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = closetDetailProvider(widget.closet.id);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // Bọc Scaffold bằng WillPopScope để xử lý nút back của hệ thống
    return PopScope(
      // canPop là false để chúng ta có thể tự điều khiển việc pop và giá trị trả về
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // Nếu việc pop chưa được thực hiện, chúng ta sẽ tự gọi nó
        // với giá trị _didChange để báo cho màn hình trước biết.
        if (!didPop) {
          Navigator.of(context).pop(_didChange);
        }
      },
      child: PageScaffold(
        appBar: state.isMultiSelectMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: notifier.clearSelectionAndExitMode,
              ),
              title: Text(l10n.closetDetail_itemsSelected(state.selectedItemIds.length)),
            )
          : AppBar(
              // Title giờ chỉ chứa tên closet, tự động xử lý overflow
              title: Text(
                widget.closet.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              // Chuyển Chip số lượng vào thuộc tính 'actions'
              actions: [
                if (!state.isLoading)
                  Padding(
                    // Thêm padding để không bị sát cạnh phải
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Chip(
                        label: Text(
                          l10n.closetDetail_itemCount(state.items.length),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        side: BorderSide.none,
                      ),
                    ),
                  ),
              ],
            ),
        body: RefreshIndicator(
          onRefresh: notifier.fetchInitialItems,
          child: CustomScrollView( // <-- Sử dụng CustomScrollView
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: PersistentHeaderDelegate(
                  // Truyền vào widget thanh tìm kiếm/lọc mới
                  child: ItemSearchFilterBar(
                    providerId: widget.closet.id, // ID của provider giờ là ID của closet
                    onApplyFilter: notifier.applyFilters,
                    // Thêm tùy chọn để ẩn bộ lọc Closet
                    showClosetFilter: false,
                    activeFilters: state.activeFilters,
                  ),
                ),
              ),
              // Xử lý các trạng thái loading/empty/error bằng Sliver
              if (state.isLoading && state.items.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.errorMessage != null && state.items.isEmpty)
                SliverFillRemaining(
                  child: Center(child: Text(state.errorMessage!)),
                )
              else if (state.items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.searchQuery.isNotEmpty
                          ? l10n.closetDetail_noItemsFound
                          : l10n.closetDetail_emptyCloset,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              else
                // GridView cũ giờ được chuyển thành SliverGrid
                _buildItemsGrid(context, ref, state.items, state.hasMore),
            ],
          ),
        ),
        // Thanh menu dưới cùng chỉ hiển thị ở chế độ chọn nhiều
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Hiệu ứng trượt từ dưới lên
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
                  key: const ValueKey('closet_detail_bottom_bar'),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Các nút bấm giữ nguyên như cũ
                      MultiSelectActionButton(
                        icon: Icons.delete_outline,
                        label: l10n.closetDetail_delete,
                        color: Colors.red,
                        onPressed: () async {
                          final confirmed = await showDeleteConfirmationDialog(
                            context,
                            title: l10n.closetDetail_confirmDeleteTitle,
                            content: Text(l10n.closetDetail_confirmDeleteContent(state.selectedItemIds.length)),
                          );
                          if (confirmed == true) {
                            await notifier.deleteSelectedItems();
                          }
                        },
                      ),
                      MultiSelectActionButton(
                        icon: Icons.move_up_outlined,
                        label: l10n.closetDetail_move,
                        onPressed: () {
                          final itemsToMove = state.items.where((item) => state.selectedItemIds.contains(item.id)).toSet();
                          _showMoveDialog(notifier, itemsToMove);
                        },
                      ),
                      MultiSelectActionButton(
                        icon: Icons.add_to_photos_outlined,
                        label: l10n.closetDetail_createOutfit,
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
              : const SizedBox.shrink(key: ValueKey('empty_closet_detail_bar')),
          ),
      )
    );
  }

  SliverPadding _buildItemsGrid(BuildContext context, WidgetRef ref, List<ClothingItem> items, bool hasMore) {
    final state = ref.watch(closetDetailProvider(widget.closet.id));
    final notifier = ref.read(closetDetailProvider(widget.closet.id).notifier);

    // Bọc SliverGrid.builder bằng SliverPadding
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid.builder( // SliverGrid.builder giờ nằm bên trong SliverPadding
        itemCount: items.length + (hasMore && !state.isMultiSelectMode ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (ctx, index) {
          // ... nội dung của itemBuilder không thay đổi
          if (index >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = items[index];
          final isSelected = state.selectedItemIds.contains(item.id);

          return GestureDetector(
            onLongPress: () {
              if (!state.isMultiSelectMode) {
                notifier.enableMultiSelectMode(item.id);
              }
            },
            onTap: () async {
              if (state.isMultiSelectMode) {
                notifier.toggleItemSelection(item.id);
              } else {
                final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemDetailNotifierArgs(tempId: item.id, itemToEdit: item));
                if (wasChanged == true) {
                  setState(() => _didChange = true);
                  ref.read(itemChangedTriggerProvider.notifier).state++;
                  ref.invalidate(closetDetailProvider(widget.closet.id));
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

class _MoveItemsDialog extends StatefulWidget {
  final List<Closet> availableClosets;
  final int itemCount;

  const _MoveItemsDialog({
    required this.availableClosets,
    required this.itemCount,
  });

  @override
  State<_MoveItemsDialog> createState() => _MoveItemsDialogState();
}

class _MoveItemsDialogState extends State<_MoveItemsDialog> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<Map<String, bool>> _showArrowsNotifier =
      ValueNotifier({'up': false, 'down': false});
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    // Thêm một frame callback để đảm bảo scrollController đã được gắn vào cây widget
    // trước khi kiểm tra trạng thái cuộn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Cập nhật trạng thái mũi tên lần đầu
        _updateArrowVisibility();
        // Gắn listener để theo dõi các thay đổi khi cuộn
        _scrollController.addListener(_updateArrowVisibility);
      }
    });
  }

  void _updateArrowVisibility() {
    if (!_scrollController.hasClients) return;
    final showUp = _scrollController.offset > 0;
    final showDown =
        _scrollController.offset < _scrollController.position.maxScrollExtent;
    // Chỉ cập nhật ValueNotifier nếu trạng thái thực sự thay đổi để tránh build lại không cần thiết
    if (showUp != _showArrowsNotifier.value['up'] ||
        showDown != _showArrowsNotifier.value['down']) {
      _showArrowsNotifier.value = {'up': showUp, 'down': showDown};
    }
  }

  @override
  void dispose() {
    // Dọn dẹp các controller một cách an toàn
    _scrollController.removeListener(_updateArrowVisibility);
    _scrollController.dispose();
    _showArrowsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.closetDetail_moveDialogTitle(widget.itemCount)), 
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: widget.availableClosets.length,
                itemBuilder: (context, index) {
                  final closet = widget.availableClosets[index];
                  return RadioListTile<String>(
                    title: Text(closet.name),
                    value: closet.id,
                    groupValue: _selectedId,
                    onChanged: (value) => setState(() => _selectedId = value),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
            // Dùng ValueListenableBuilder để chỉ build lại các mũi tên
            ValueListenableBuilder<Map<String, bool>>(
              valueListenable: _showArrowsNotifier,
              builder: (context, arrowsState, _) {
                return Stack(
                  children: [
                    if (arrowsState['up'] ?? false)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Icon(Icons.keyboard_arrow_up,
                              size: 24, color: Colors.grey),
                        ),
                      ),
                    if (arrowsState['down'] ?? false)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Icon(Icons.keyboard_arrow_down,
                              size: 24, color: Colors.grey),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.closetDetail_cancel)),
        ElevatedButton(
          onPressed:
              _selectedId == null ? null : () => Navigator.of(context).pop(_selectedId),
          child: Text(l10n.closetDetail_move),
        ),
      ],
    );
  }
}