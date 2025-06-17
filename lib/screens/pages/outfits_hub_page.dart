// lib/screens/pages/outfits_hub_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/outfit_providers.dart';
import 'package:mincloset/screens/outfit_detail_page.dart';
import 'package:mincloset/screens/pages/outfit_builder_page.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart';

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
          // GridView giờ đây sẽ luôn hiển thị các bộ đồ + 1 ô để "Thêm mới"
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            // <<< THAY ĐỔI 1: Tăng itemCount lên 1
            itemCount: outfits.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (ctx, index) {
              // <<< THAY ĐỔI 2: Thêm logic để build ô đầu tiên
              if (index == 0) {
                // Nếu là item đầu tiên, build Card "Thêm bộ đồ mới"
                return _buildAddOutfitCard(context, ref);
              }

              // Các item còn lại sẽ là các bộ đồ đã lưu
              final outfit = outfits[index - 1]; // Dùng index - 1
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
                          OutfitActionsMenu(
                            outfit: outfit,
                            onUpdate: () {
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
      // <<< THAY ĐỔI 3: Xóa bỏ FloatingActionButton
    );
  }

  // <<< THÊM HÀM MỚI ĐỂ BUILD CARD "THÊM BỘ ĐỒ"
  Widget _buildAddOutfitCard(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final bool? newOutfitCreated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (context) => const OutfitBuilderPage())
        );
        if (newOutfitCreated == true) {
          ref.invalidate(outfitsProvider);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              const Text(
                'Tạo bộ đồ mới',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}