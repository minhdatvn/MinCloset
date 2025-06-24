// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';

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
          onPressed: () async {
            final success = await ref.read(closetsPageProvider.notifier).addCloset(nameController.text);
            if (success && context.mounted) {
              Navigator.of(ctx).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

// Các lớp ClosetsPage và _ClosetsPageState không thay đổi
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Closet'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'By Closet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _AllItemsTab(),
          const _ClosetsListTab(),
        ],
      ),
    );
  }
}

// Lớp _AllItemsTabState không thay đổi, chỉ sửa hàm build
class _AllItemsTab extends ConsumerStatefulWidget {
  const _AllItemsTab();
  @override
  ConsumerState<_AllItemsTab> createState() => _AllItemsTabState();
}

class _AllItemsTabState extends ConsumerState<_AllItemsTab> {
  final ScrollController _scrollController = ScrollController();
  static const providerId = 'closetsPage';

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
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    
    return RefreshIndicator(
      onRefresh: notifier.fetchInitialItems,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // <<< THAY ĐỔI Ở ĐÂY: Dùng SliverPersistentHeader >>>
          SliverPersistentHeader(
            pinned: true, // Thuộc tính này sẽ ghim widget lại
            delegate: _SliverAppBarDelegate(
              const ItemSearchFilterBar(providerId: providerId),
            ),
          ),
          ItemBrowserView(
            providerId: providerId,
            onItemTapped: (item) async {
              final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemNotifierArgs(tempId: item.id, itemToEdit: item));
              if (wasChanged == true) {
                ref.read(itemAddedTriggerProvider.notifier).state++;
              }
            },
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