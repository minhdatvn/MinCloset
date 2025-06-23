// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';

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
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () async {
            final success = await ref.read(closetsPageProvider.notifier).addCloset(nameController.text);
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
    
    return Column(
      children: [
        // <<< THAY THẾ TOÀN BỘ PADDING VÀ ROW CŨ BẰNG WIDGET MỚI NÀY >>>
        ItemSearchFilterBar(providerId: providerId),
        // -----------------------------------------------------------
        Expanded(
          child: ItemBrowserView(
            providerId: providerId,
            onItemTapped: (item) async {
              final wasChanged = await Navigator.pushNamed(context, AppRoutes.addItem, arguments: ItemNotifierArgs(tempId: item.id, itemToEdit: item));
              if (wasChanged == true) {
                ref.read(itemAddedTriggerProvider.notifier).state++;
              }
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
                leading: Icon(
                  Icons.add_circle_outline, 
                  color: theme.colorScheme.primary
                ),
                title: Text(
                  'Thêm tủ đồ mới...',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold
                  ),
                ),
                onTap: () => _showAddClosetDialog(context, ref),
              );
            }

            final closet = closets[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.closetDetail, arguments: closet);
              },
            );
          },
        );
      },
    );
  }
}