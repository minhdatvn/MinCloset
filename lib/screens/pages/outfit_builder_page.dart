// lib/screens/pages/outfit_builder_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/widgets/clothing_sticker.dart';
import 'package:mincloset/widgets/filter_bottom_sheet.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
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
    // Đợi một chút để UI cập nhật (bỏ viền xanh) trước khi chụp ảnh
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

    ref.listen(outfitBuilderProvider, (previous, next) {
      if (next.saveSuccess && previous?.saveSuccess == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu bộ đồ thành công!')));
        Navigator.of(context).pop(true);
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
      body: Stack(
        children: [
          Screenshot(
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
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _ItemSelectionPanel(scrollController: scrollController),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Lớp Delegate để tạo Header cố định (sticky)
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

/// Widget con mới, được cấu trúc lại để sử dụng CustomScrollView
class _ItemSelectionPanel extends HookConsumerWidget {
  final ScrollController scrollController;
  const _ItemSelectionPanel({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const providerId = 'outfitBuilderPage';
    final state = ref.watch(itemFilterProvider(providerId));
    final notifier = ref.read(itemFilterProvider(providerId).notifier);
    final searchController = useTextEditingController();
    final closetsAsync = ref.watch(closetsProvider);

    useEffect(() {
      if (searchController.text != state.searchQuery) {
        searchController.text = state.searchQuery;
      }
      return null;
    }, [state.searchQuery]);

    // Sử dụng CustomScrollView để có thể ghim header
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Header chứa thanh cầm, tìm kiếm và lọc.
        // Header này sẽ được ghim lại ở trên cùng.
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelegate(
            height: 80, // Chiều cao của header
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm vật phẩm...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: notifier.setSearchQuery,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Badge(
                            isLabelVisible: state.activeFilters.isApplied,
                            child: const Icon(Icons.filter_list),
                          ),
                          tooltip: 'Lọc nâng cao',
                          onPressed: () {
                            closetsAsync.whenData((closets) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                  child: FilterBottomSheet(
                                    currentFilter: state.activeFilters,
                                    closets: closets,
                                    onApplyFilter: notifier.applyFilters,
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Phần còn lại là lưới các item, có thể cuộn được
        ItemBrowserView(
          providerId: providerId,
          onItemTapped: (ClothingItem item) {
            ref.read(outfitBuilderProvider.notifier).addItemToCanvas(item);
          },
        ),
      ],
    );
  }
}