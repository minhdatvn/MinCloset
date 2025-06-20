// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:mincloset/widgets/filter_bottom_sheet.dart';
import 'package:mincloset/widgets/item_browser_view.dart';

void _showAddClosetDialog(BuildContext context, WidgetRef ref) {
  final nameController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Tạo tủ đồ mới'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Tên tủ đồ'),
        autofocus: true,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            final success = await ref
                .read(closetsPageProvider.notifier)
                .addCloset(nameController.text);
            if (success && context.mounted) {
              Navigator.of(ctx).pop();
            }
          },
          child: const Text('Lưu'),
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

class _ClosetsPageState extends ConsumerState<ClosetsPage>
    with SingleTickerProviderStateMixin {
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
        title: const Text('Tủ đồ của bạn'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả vật phẩm'),
            Tab(text: 'Theo Tủ đồ'),
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

class _AllItemsTab extends HookConsumerWidget {
  const _AllItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const providerId = 'closetsPage';
    final state = ref.watch(itemFilterProvider(providerId));
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    final searchController = useTextEditingController();
    final closetsAsync = ref.watch(closetsProvider);

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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
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
          child: ItemBrowserView(
            providerId: providerId,
            onItemTapped: (item) {
              Navigator.of(context).push<bool>(
                MaterialPageRoute(
                    builder: (context) => AddItemScreen(itemToEdit: item)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClosetsListTab extends ConsumerWidget {
  const _ClosetsListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closetsAsyncValue = ref.watch(closetsProvider);
    final theme = Theme.of(context);

    return closetsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (closets) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: closets.length + 1,
          itemBuilder: (ctx, index) {
            if (index == closets.length) {
              return ListTile(
                leading:
                    Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                title: Text(
                  'Thêm tủ đồ mới...',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () => _showAddClosetDialog(context, ref),
              );
            }

            final closet = closets[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title:
                  Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ClosetDetailPage(closet: closet)),
                );
              },
            );
          },
        );
      },
    );
  }
}