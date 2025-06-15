// lib/screens/pages/outfit_builder_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/widgets/clothing_sticker.dart';
import 'package:screenshot/screenshot.dart';

class OutfitBuilderPage extends ConsumerStatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  ConsumerState<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends ConsumerState<OutfitBuilderPage> {
  final _screenshotController = ScreenshotController();

  Future<void> _saveOutfit() async {
    final notifier = ref.read(outfitBuilderProvider.notifier);
    final outfitName = await _showNameOutfitDialog();
    if (outfitName == null || outfitName.trim().isEmpty) return;
    
    // Bỏ chọn sticker trước khi chụp ảnh
    notifier.deselectAllStickers();
    await Future.delayed(const Duration(milliseconds: 50)); // Đợi UI cập nhật

    final capturedImage = await _screenshotController.capture();
    if (capturedImage != null) {
      await notifier.saveOutfit(outfitName, capturedImage);
    }
  }

  Future<String?> _showNameOutfitDialog() {
    final nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt tên cho bộ đồ'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Ví dụ: Dạo phố cuối tuần'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(nameController.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outfitBuilderProvider);
    final notifier = ref.read(outfitBuilderProvider.notifier);
    
    ref.listen(outfitBuilderProvider, (previous, next) {
      if (next.saveSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu bộ đồ thành công!')));
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xưởng Phối đồ'),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveOutfit,
              tooltip: 'Lưu bộ đồ',
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: GestureDetector(
                onTap: notifier.deselectAllStickers,
                child: Container(
                  color: Colors.grey.shade200,
                  child: Stack(
                    children: state.itemsOnCanvas.entries.map((entry) {
                      final stickerId = entry.key;
                      final item = entry.value;
                      return ClothingSticker(
                        key: ValueKey(stickerId),
                        item: item,
                        isSelected: stickerId == state.selectedStickerId,
                        onSelect: () => notifier.selectSticker(stickerId),
                        onDelete: () => notifier.deleteSticker(stickerId),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 120,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.availableItems.length,
                    itemBuilder: (ctx, index) {
                      final item = state.availableItems[index];
                      return GestureDetector(
                        onTap: () => notifier.addItemToCanvas(item),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Image.file(File(item.imagePath), fit: BoxFit.contain),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}