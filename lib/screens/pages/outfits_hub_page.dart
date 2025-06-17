// lib/screens/pages/outfits_hub_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/outfit_providers.dart';
import 'package:mincloset/screens/outfit_detail_page.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart'; // <<< THÊM IMPORT NÀY

class OutfitsHubPage extends ConsumerWidget {
  const OutfitsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitsAsyncValue = ref.watch(outfitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang phục của bạn'),
      ),
      body: outfitsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (outfits) {
          if (outfits.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa có bộ đồ nào.\nHãy bấm nút + để sáng tạo nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
                      child: GestureDetector(
                        onTap: () async {
                          final bool? outfitWasChanged = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (_) => OutfitDetailPage(outfit: outfit)),
                          );
                          if (outfitWasChanged == true) {
                            ref.invalidate(outfitsProvider);
                          }
                        },
                        child: Image.file(
                          File(outfit.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          
                          // <<< THAY THẾ POPUPMENUBUTTON CŨ BẰNG WIDGET DÙNG CHUNG MỚI
                          OutfitActionsMenu(
                            outfit: outfit,
                            onUpdate: () {
                              // Khi có cập nhật từ menu (đổi tên, xóa),
                              // làm mới lại danh sách
                              ref.invalidate(outfitsProvider);
                            },
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
        onPressed: () async {
          final bool? newOutfitCreated = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (context) => const OutfitBuilderPage())
          );
          if (newOutfitCreated == true) {
            ref.invalidate(outfitsProvider);
          }
        },
        label: const Text('Tạo bộ đồ mới'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}