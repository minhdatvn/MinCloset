// lib/screens/pages/outfit_builder_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/database_providers.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/widgets/filter_bottom_sheet.dart'; // <<< THÊM IMPORT NÀY
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
    
    notifier.deselectAllStickers();
    await Future.delayed(const Duration(milliseconds: 50));

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
    // Lấy danh sách tủ đồ để truyền vào bottom sheet
    final closetsAsync = ref.watch(closetsProvider);
    
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
          
          // <<< THAY THẾ TOÀN BỘ PHẦN CHỌN ĐỒ Ở ĐÂY
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. HÀNG HIỂN THỊ NÚT LỌC
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.filter_list),
                        label: Text('Lọc${state.activeFilters.isApplied ? ' (Đang áp dụng)' : ''}'),
                        onPressed: () {
                          // Chỉ hiển thị bottom sheet khi đã tải xong danh sách tủ đồ
                          closetsAsync.whenData((closets) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, // Cho phép bottom sheet cao hơn
                              builder: (_) => FilterBottomSheet(
                                currentFilter: state.activeFilters,
                                closets: closets,
                              ),
                            );
                          });
                        },
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 2. DANH SÁCH VẬT PHẨM (ĐÃ ĐƯỢC LỌC)
                SizedBox(
                  height: 100,
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.filteredItems.isEmpty
                          ? const Center(child: Text('Không có vật phẩm nào phù hợp.'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              itemCount: state.filteredItems.length,
                              itemBuilder: (ctx, index) {
                                final item = state.filteredItems[index];
                                return GestureDetector(
                                  onTap: () => notifier.addItemToCanvas(item),
                                  child: Container(
                                    width: 90,
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300)
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(item.imagePath), fit: BoxFit.contain)
                                    ),
                                  ),
                                );
                              },
                            ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}