// lib/screens/pages/saved_outfits_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/outfit_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart'; // <<< THÊM IMPORT NÀY
import 'package:share_plus/share_plus.dart';

// Tên lớp đã được đổi
class OutfitsHubPage extends ConsumerWidget {
  const OutfitsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitsAsyncValue = ref.watch(outfitsProvider);

    return Scaffold(
      appBar: AppBar(
        // Đổi tiêu đề cho phù hợp
        title: const Text('Trang phục của bạn'),
      ),
      body: outfitsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (outfits) {
          if (outfits.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có bộ đồ nào.\nHãy bấm nút + để sáng tạo nhé!', // Sửa lại text cho phù hợp
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          // GridView hiển thị các bộ đồ đã lưu giữ nguyên
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Thêm padding dưới để không bị FAB che
            itemCount: outfits.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (ctx, index) {
              final outfit = outfits[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.file(
                        File(outfit.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blue),
                            onPressed: () => _shareOutfit(context, outfit),
                            tooltip: 'Chia sẻ',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteOutfit(context, ref, outfit),
                            tooltip: 'Xóa',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Khi bấm, điều hướng đến Xưởng Phối đồ
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const OutfitBuilderPage())
          );
        },
        label: const Text('Tạo bộ đồ mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _shareOutfit(BuildContext context, Outfit outfit) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Cùng xem bộ đồ "${outfit.name}" của tôi trên MinCloset nhé!',
          files: [XFile(outfit.imagePath)],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chia sẻ: $e')),
        );
      }
    }
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref, Outfit outfit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn bộ đồ "${outfit.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // <<< THAY ĐỔI: Gọi đến Repository thay vì DatabaseHelper
      await ref.read(outfitRepositoryProvider).deleteOutfit(outfit.id);
      
      try {
        final imageFile = File(outfit.imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (e) {
        debugPrint("Lỗi khi xóa file ảnh: $e");
      }
      
      ref.invalidate(outfitsProvider);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa bộ đồ "${outfit.name}".')),
        );
      }
    }
  }
}