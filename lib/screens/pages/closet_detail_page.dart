// lib/screens/pages/closet_detail_page.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart'; // <<< Dùng lại provider này
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

// <<< Quay trở lại dùng ConsumerWidget đơn giản, không cần Hook hay State
class ClosetDetailPage extends ConsumerWidget {
  final Closet closet;
  const ClosetDetailPage({super.key, required this.closet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // <<< Dùng lại provider family đơn giản ban đầu để lấy dữ liệu
    final itemsAsyncValue = ref.watch(itemsInClosetProvider(closet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(closet.name),
        // <<< Bỏ thanh tìm kiếm ở đây
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm đồ vào tủ này',
            onPressed: () async {
              final itemWasAdded = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (ctx) => AddItemScreen(preselectedClosetId: closet.id)),
              );
              // Nếu có đồ được thêm, làm mới lại danh sách
              if (itemWasAdded == true) {
                ref.invalidate(itemsInClosetProvider(closet.id));
              }
            },
          ),
        ],
      ),
      // <<< Dùng .when() để xử lý các trạng thái loading/error/data
      body: itemsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Tủ đồ này chưa có gì cả.\nHãy nhấn nút + ở trên để thêm nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          // Gọi hàm helper để build GridView
          return _buildItemsGrid(context, ref, items);
        },
      ),
    );
  }

  // Hàm helper để build GridView hiển thị các vật phẩm
  Widget _buildItemsGrid(BuildContext context, WidgetRef ref, List<ClothingItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (ctx, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () async {
          // <<< THAY ĐỔI Ở ĐÂY: Điều hướng đến AddItemScreen thay vì ItemDetailPage
          final itemWasChanged = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => AddItemScreen(itemToEdit: item)),
          );
          if (itemWasChanged == true && context.mounted) {
            final closetId = item.closetId;
            ref.invalidate(itemsInClosetProvider(closetId));
          }
        },
        child: RecentItemCard(item: item),
        );
      },
    );
  }
}