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

// Lớp OutfitBuilderPage không có gì thay đổi
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
          Align(
            alignment: Alignment.topCenter,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Screenshot(
                controller: _screenshotController,
                child: GestureDetector(
                  onTap: notifier.deselectAllStickers,
                  child: Container(
                    color: Colors.white,
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
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.32,
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

class _ItemSelectionPanel extends HookConsumerWidget {
  final ScrollController scrollController;
  const _ItemSelectionPanel({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const providerId = 'outfitBuilderPage';
    final filterState = ref.watch(itemFilterProvider(providerId));
    final filterNotifier = ref.read(itemFilterProvider(providerId).notifier);
    final searchController = useTextEditingController();
    final closetsAsync = ref.watch(closetsProvider);

    // <<< BƯỚC 1: LẤY DỮ LIỆU TỪ OUTFITBUILDERPROVIDER
    final canvasItems = ref.watch(outfitBuilderProvider.select((state) => state.itemsOnCanvas.values));

    // <<< BƯỚC 2: TÍNH TOÁN SỐ LƯỢNG
    final Map<String, int> itemCounts = {};
    for (final item in canvasItems) {
      itemCounts[item.id] = (itemCounts[item.id] ?? 0) + 1;
    }

    useEffect(() {
      if (searchController.text != filterState.searchQuery) {
        searchController.text = filterState.searchQuery;
      }
      return null;
    }, [filterState.searchQuery]);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelegate(
            height: 78,
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
                            onChanged: filterNotifier.setSearchQuery,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Badge(
                            isLabelVisible: filterState.activeFilters.isApplied,
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
                                    currentFilter: filterState.activeFilters,
                                    closets: closets,
                                    onApplyFilter: filterNotifier.applyFilters,
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
        ItemBrowserView(
          providerId: providerId,
          onItemTapped: (ClothingItem item) {
            ref.read(outfitBuilderProvider.notifier).addItemToCanvas(item);
          },
          // <<< BƯỚC 3: TRUYỀN MAP SỐ ĐẾM XUỐNG
          itemCounts: itemCounts,
        ),
      ],
    );
  }
}