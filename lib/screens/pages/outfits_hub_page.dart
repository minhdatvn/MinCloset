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
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: outfits.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return _buildAddOutfitCard(context, ref);
              }

              final outfit = outfits[index - 1];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      // <<< BỌC HÌNH ẢNH TRONG STACK ĐỂ THÊM ICON >>>
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
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
                          // <<< THÊM ICON KHÓA NẾU LÀ BỘ ĐỒ CỐ ĐỊNH >>>
                          if (outfit.isFixed)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(153),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                              ),
                            )
                        ],
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
    );
  }

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