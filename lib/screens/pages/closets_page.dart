// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:uuid/uuid.dart';

// <<< BƯỚC 1: Di chuyển hàm dialog ra ngoài để có thể gọi từ bất kỳ đâu trong file
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
        // <<< BƯỚC 2: Xóa bỏ thuộc tính `actions` khỏi AppBar
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
          _ClosetsListTab(),
        ],
      ),
      // <<< BƯỚC 3: Xóa bỏ `floatingActionButton` khỏi Scaffold
    );
  }
}

/// Widget cho Tab 1: Hiển thị tất cả vật phẩm và thanh tìm kiếm
class _AllItemsTab extends ConsumerWidget {
  const _AllItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(itemAddedTriggerProvider, (previous, next) {
      if (previous != next) {
        ref.invalidate(itemFilterProvider('closetsPage'));
      }
    });

    return ItemBrowserView(
      providerId: 'closetsPage',
      onItemTapped: (item) {
        // Hành động khi bấm vào item ở tab này là xem/sửa chi tiết
        Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (context) => AddItemScreen(itemToEdit: item)),
        ).then((wasChanged) {
          if (wasChanged == true) {
            ref.invalidate(itemFilterProvider('closetsPage'));
          }
        });
      },
    );
  }
}

/// Widget cho Tab 2: Hiển thị danh sách các tủ đồ
class _ClosetsListTab extends ConsumerWidget {
  const _ClosetsListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closetsAsyncValue = ref.watch(closetsProvider);
    return closetsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (closets) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          // <<< BƯỚC 4: Tăng itemCount lên 1 để chứa dòng "Thêm tủ đồ"
          itemCount: closets.length + 1,
          itemBuilder: (ctx, index) {
            // <<< BƯỚC 5: Thêm logic để hiển thị dòng cuối cùng
            if (index == closets.length) {
              // Đây là dòng cuối cùng
              return ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                title: const Text(
                  'Thêm tủ đồ mới...',
                  style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
                onTap: () => _showAddClosetDialog(context, ref), // Gọi hàm đã được di chuyển ra ngoài
              );
            }

            // Các dòng bình thường hiển thị tủ đồ
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