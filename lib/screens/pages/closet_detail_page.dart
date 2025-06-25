// lib/screens/pages/closet_detail_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/closet_detail_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

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
    final closets = await ref.read(closetsProvider.future);
    // Loại bỏ tủ đồ hiện tại khỏi danh sách lựa chọn
    final availableClosets = closets.where((c) => c.id != widget.closet.id).toList();

    if (!mounted) return;
    if (availableClosets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No other closets available to move to.')));
      return;
    }

    final String? targetClosetId = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Move ${itemsToMove.length} items to...'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableClosets.length,
            itemBuilder: (context, index) {
              final closet = availableClosets[index];
              return ListTile(
                title: Text(closet.name),
                onTap: () => Navigator.of(ctx).pop(closet.id),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel'))],
      ),
    );

    if (targetClosetId != null) {
      await notifier.moveSelectedItems(targetClosetId);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        appBar: state.isMultiSelectMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: notifier.clearSelectionAndExitMode,
              ),
              title: Text('${state.selectedItemIds.length} selected'),
            )
          : AppBar(title: Text(widget.closet.name)),
        body: RefreshIndicator(
          onRefresh: notifier.fetchInitialItems,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search in this closet...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: notifier.search,
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  if (state.isLoading && state.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.errorMessage != null && state.items.isEmpty) {
                    return Center(child: Text(state.errorMessage!));
                  }
                  if (state.items.isEmpty) {
                    return Center(
                      child: Text(
                        state.searchQuery.isNotEmpty ? 'No items found.' : 'This closet is empty.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return _buildItemsGrid(context, ref, state.items, state.hasMore);
                }),
              ),
            ],
          ),
        ),
        // Thanh menu dưới cùng chỉ hiển thị ở chế độ chọn nhiều
        bottomNavigationBar: state.isMultiSelectMode
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    onPressed: notifier.deleteSelectedItems,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.move_up_outlined),
                    label: const Text('Move'),
                    onPressed: () {
                      final itemsToMove = state.items.where((item) => state.selectedItemIds.contains(item.id)).toSet();
                      _showMoveDialog(notifier, itemsToMove);
                    },
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

  Widget _buildItemsGrid(BuildContext context, WidgetRef ref, List<ClothingItem> items, bool hasMore) {
    final state = ref.watch(closetDetailProvider(widget.closet.id));
    final notifier = ref.read(closetDetailProvider(widget.closet.id).notifier);

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length + (hasMore && !state.isMultiSelectMode ? 1 : 0),
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
            if (!state.isMultiSelectMode) {
              notifier.enableMultiSelectMode(item.id);
            }
          },
          onTap: () async {
            if (state.isMultiSelectMode) {
              notifier.toggleItemSelection(item.id);
            } else {
              final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemNotifierArgs(tempId: item.id, itemToEdit: item));
              if (wasChanged == true) {
                setState(() => _didChange = true);
                ref.read(itemAddedTriggerProvider.notifier).state++;
                ref.invalidate(closetDetailProvider(widget.closet.id));
              }
            }
          },
          child: RecentItemCard(item: item, isSelected: isSelected),
        );
      },
    );
  }
}