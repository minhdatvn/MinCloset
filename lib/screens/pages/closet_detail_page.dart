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
            onPressed: () async {
              // Cũng xử lý kết quả trả về từ màn hình AddItemScreen
              final bool? itemWasAdded = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (ctx) => AddItemScreen(preselectedClosetId: closet.id),
                ),
              );

              if (itemWasAdded == true && context.mounted) {
                ref.invalidate(itemsInClosetProvider(closet.id));
              }
            },
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
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
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
                // <<< TOÀN BỘ LOGIC SỬA LỖI NẰM Ở ĐÂY
                onTap: () async {
                  // 1. Dùng `async` và `await` để chờ kết quả trả về
                  final bool? itemWasChanged = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(item: item),
                    ),
                  );

                  // 2. Nếu kết quả trả về là `true` (tức là có thay đổi)
                  // và widget vẫn còn tồn tại trên cây widget (`context.mounted`)
                  if (itemWasChanged == true && context.mounted) {
                    // 3. Làm mới provider để tải lại danh sách từ CSDL
                    ref.invalidate(itemsInClosetProvider(closet.id));
                  }
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