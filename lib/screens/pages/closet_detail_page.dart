// lib/screens/pages/closet_detail_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart'; // <<< THÊM import
import 'package:mincloset/notifiers/closet_detail_notifier.dart'; // <<< THÊM import
import 'package:mincloset/providers/event_providers.dart'; // <<< THÊM import
import 'package:mincloset/routing/app_routes.dart'; // <<< THÊM import
import 'package:mincloset/widgets/recent_item_card.dart';

// <<< SỬA ĐỔI: Chuyển thành ConsumerStatefulWidget >>>
class ClosetDetailPage extends ConsumerStatefulWidget {
  final Closet closet;
  const ClosetDetailPage({super.key, required this.closet});

  @override
  ConsumerState<ClosetDetailPage> createState() => _ClosetDetailPageState();
}

class _ClosetDetailPageState extends ConsumerState<ClosetDetailPage> {
  final ScrollController _scrollController = ScrollController();

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
    // <<< SỬA ĐỔI: Lắng nghe provider mới >>>
    final state = ref.watch(closetDetailProvider(widget.closet.id));
    final notifier = ref.read(closetDetailProvider(widget.closet.id).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.closet.name),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.fetchInitialItems,
        child: Column(
          children: [
            // <<< THÊM MỚI: Thanh tìm kiếm >>>
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search in this closet...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: notifier.search,
              ),
            ),
            // <<< SỬA ĐỔI: Xử lý hiển thị danh sách >>>
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
                      state.searchQuery.isNotEmpty
                          ? 'No items found.'
                          : 'This closet is empty.',
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
    );
  }

  Widget _buildItemsGrid(BuildContext context, WidgetRef ref, List<ClothingItem> items, bool hasMore) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length + (hasMore ? 1 : 0),
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
        return GestureDetector(
          onTap: () async {
            // Logic điều hướng và làm mới không thay đổi
            final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemNotifierArgs(tempId: item.id, itemToEdit: item));
            if (wasChanged == true) {
              ref.read(itemAddedTriggerProvider.notifier).state++;
              // Thêm dòng này để cập nhật lại danh sách của closet cụ thể này
              ref.invalidate(closetDetailProvider(widget.closet.id));
            }
          },
          child: RecentItemCard(item: item),
        );
      },
    );
  }
}