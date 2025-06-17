// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            tooltip: 'Thêm vật phẩm mới',
            onPressed: () async {
              final bool? itemWasAdded = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (context) => const AddItemScreen()),
              );

              if (itemWasAdded == true) {
                ref.invalidate(itemFilterProvider('closetsPage'));
              }
            },
          )
        ],
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
          // Widget cho Tab 1: Tìm kiếm toàn cục
          _AllItemsTab(),
          // Widget cho Tab 2: Danh sách tủ đồ
          _ClosetsListTab(),
        ],
      ),
      // FAB giờ dùng để thêm tủ đồ mới
      floatingActionButton: FloatingActionButton(
        heroTag: 'closets_page_fab',
        onPressed: () => _showAddClosetDialog(context, ref),
        tooltip: 'Tạo tủ đồ mới',
        child: const Icon(Icons.add_business_outlined),
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

/// Widget cho Tab 1: Hiển thị tất cả vật phẩm và thanh tìm kiếm
class _AllItemsTab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // <<< BƯỚC 4: THÊM `ref.listen` VÀO ĐÂY
    // Lắng nghe sự thay đổi của trigger provider.
    // Tham số `previous` và `next` là giá trị cũ và mới của state trong provider.
    ref.listen<int>(itemAddedTriggerProvider, (previous, next) {
      // Khi có tín hiệu mới (giá trị thay đổi), làm mới lại danh sách vật phẩm
      // Bằng cách vô hiệu hóa provider của chính nó.
      ref.invalidate(itemFilterProvider('closetsPage'));
    });

    return ItemBrowserView(
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
          return const Center(child: Text('Bạn chưa có tủ đồ nào.\nHãy bấm nút + ở trên để tạo nhé!', textAlign: TextAlign.center));
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