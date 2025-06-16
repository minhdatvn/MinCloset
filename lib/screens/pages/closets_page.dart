// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/screens/item_detail_page.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:uuid/uuid.dart';

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
          ItemBrowserView(
            providerId: 'closetsPage',
            onItemTapped: (item) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ItemDetailPage(item: item)),
              ).then((itemWasChanged) {
                if (itemWasChanged == true) {
                  ref.invalidate(itemFilterProvider('closetsPage'));
                }
              });
            },
          ),
          _ClosetsListTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'closets_page_fab',
        onPressed: () => _showAddClosetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddClosetDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo tủ đồ mới'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên tủ đồ'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final newCloset = Closet(id: const Uuid().v4(), name: nameController.text.trim());
              
              // <<< THAY ĐỔI Ở ĐÂY: Bỏ `new Closet(...)` và dùng thẳng biến `newCloset`
              await ref.read(closetRepositoryProvider).insertCloset(newCloset);
              
              ref.invalidate(closetsProvider);
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

/// Widget cho Tab 2: Hiển thị danh sách các tủ đồ
class _ClosetsListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closetsAsyncValue = ref.watch(closetsProvider);
    return closetsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (closets) {
        if (closets.isEmpty) {
          return const Center(child: Text('Bạn chưa có tủ đồ nào.\nHãy bấm nút + để tạo nhé!', textAlign: TextAlign.center));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: closets.length,
          itemBuilder: (ctx, index) {
            final closet = closets[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ClosetDetailPage(closet: closet)),
                );
              },
            );
          },
        );
      },
    );
  }
}