// lib/screens/pages/closets_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/repository_providers.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:uuid/uuid.dart';

class ClosetsPage extends ConsumerWidget {
  const ClosetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Phần này đã đúng, nó đọc closetsProvider (đã dùng repository)
    final closetsAsyncValue = ref.watch(closetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tủ đồ'),
      ),
      body: closetsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
        data: (closets) {
          if (closets.isEmpty) {
            return const Center(child: Text('Bạn chưa có tủ đồ nào.'));
          }
          return ListView.builder(
            itemCount: closets.length,
            itemBuilder: (ctx, index) {
              final closet = closets[index];
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showEditClosetDialog(context, ref, closet), tooltip: 'Sửa tên'),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteConfirmDialog(context, ref, closet), tooltip: 'Xóa tủ đồ'),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ClosetDetailPage(closet: closet)),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'closets_page_fab',
        onPressed: () => _showAddClosetDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- LOGIC CHO CÁC HÀNH ĐỘNG ĐÃ ĐƯỢC CẬP NHẬT ---

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
              
              // <<< THAY ĐỔI: Gọi đến Repository thay vì DatabaseHelper
              await ref.read(closetRepositoryProvider).insertCloset(newCloset);
              
              // Vô hiệu hóa provider để làm mới UI
              ref.invalidate(closetsProvider);
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
  
  void _showEditClosetDialog(BuildContext context, WidgetRef ref, Closet closet) {
    final nameController = TextEditingController(text: closet.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa tên tủ đồ'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên mới'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final updatedCloset = Closet(id: closet.id, name: nameController.text.trim());

              // <<< THAY ĐỔI: Gọi đến Repository thay vì DatabaseHelper
              await ref.read(closetRepositoryProvider).updateCloset(updatedCloset);
              
              ref.invalidate(closetsProvider);
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Closet closet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa tủ đồ "${closet.name}"? Mọi món đồ bên trong cũng sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              // <<< THAY ĐỔI: Gọi đến Repository thay vì DatabaseHelper
              await ref.read(closetRepositoryProvider).deleteCloset(closet.id);

              ref.invalidate(closetsProvider);
              if (context.mounted) Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}