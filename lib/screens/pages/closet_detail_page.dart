// lib/screens/pages/closet_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/item_detail_page.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

class ClosetDetailPage extends ConsumerWidget {
  final Closet closet;
  const ClosetDetailPage({super.key, required this.closet});

  // <<< BƯỚC 1: ĐỊNH NGHĨA LẠI HÀM HELPER Ở ĐÂY
  // Hàm này được định nghĩa bên trong lớp ConsumerWidget, bên ngoài hàm build.
  // Chúng ta truyền các tham số cần thiết vào thay vì dùng "widget" hay "context" ngầm định.
  void _navigateToAddItem(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push<bool>( // Thêm kiểu <bool> để nhận kết quả trả về
      MaterialPageRoute(
        builder: (ctx) => AddItemScreen(preselectedClosetId: closet.id),
      ),
    ).then((wasItemAdded) {
      // Khi màn hình AddItemScreen đóng lại và trả về giá trị `true`,
      // có nghĩa là một món đồ mới đã được thêm thành công.
      if (wasItemAdded == true) {
        // Ta chỉ cần "invalidate" provider. Riverpod sẽ tự động fetch lại dữ liệu mới
        // và cập nhật UI. Đây là cách làm mới dữ liệu thay cho setState().
        ref.invalidate(itemsInClosetProvider(closet.id));
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(itemsInClosetProvider(closet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(closet.name),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm đồ vào tủ này',
            // <<< BƯỚC 2: SỬA LẠI LỜI GỌI HÀM
            // Gọi hàm đã được định nghĩa ở trên.
            onPressed: () => _navigateToAddItem(context, ref),
          ),
        ],
      ),
      body: itemsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Tủ đồ này chưa có gì cả.\nHãy nhấn nút + ở trên để thêm nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 3 / 4, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemBuilder: (ctx, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(item: item),
                    ),
                  ).then((result) {
                    if (result == true) {
                      ref.invalidate(itemsInClosetProvider(closet.id));
                    }
                  });
                },
                child: RecentItemCard(item: item),
              );
            },
          );
        },
      ),
    );
  }
}