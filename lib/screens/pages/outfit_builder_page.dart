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

  // <<< CẬP NHẬT HÀM LƯU >>>
  Future<void> _saveOutfit() async {
    final notifier = ref.read(outfitBuilderProvider.notifier);
    // Lấy kết quả từ dialog, giờ đây là một Map
    final result = await _showNameOutfitDialog();

    // Nếu người dùng nhấn Hủy hoặc không nhập tên, result sẽ là null
    if (result == null) return;
    
    final String name = result['name'] as String;
    final bool isFixed = result['isFixed'] as bool;

    if (name.trim().isEmpty) return;

    notifier.deselectAllStickers();
    await Future.delayed(const Duration(milliseconds: 50));

    final capturedImage = await _screenshotController.capture();
    if (capturedImage != null) {
      // Truyền thêm cờ isFixed vào hàm saveOutfit của notifier
      await notifier.saveOutfit(name, isFixed, capturedImage);
    }
  }

  // <<< CẬP NHẬT HỘP THOẠI LƯU >>>
  Future<Map<String, dynamic>?> _showNameOutfitDialog() {
    final nameController = TextEditingController();
    bool isFixed = false; // Trạng thái ban đầu của switch

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        // Sử dụng StatefulBuilder để dialog có thể tự cập nhật trạng thái của Switch
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Lưu bộ đồ'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Giúp Column co lại vừa với nội dung
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(hintText: 'Ví dụ: Dạo phố cuối tuần'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // SwitchListTile để có tiêu đề và nút switch tiện lợi
                  SwitchListTile(
                    title: const Text(
                      'Bộ đồ cố định',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Các món đồ sẽ luôn được gợi ý cùng nhau (dùng cho đồng phục, suit...).',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: isFixed,
                    onChanged: (newValue) {
                      // Cập nhật trạng thái của Switch khi người dùng tương tác
                      setState(() {
                        isFixed = newValue;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    // Trả về một Map chứa cả tên và trạng thái của switch
                    Navigator.of(ctx).pop({
                      'name': nameController.text.trim(),
                      'isFixed': isFixed,
                    });
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
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

    final canvasItems = ref.watch(outfitBuilderProvider.select((state) => state.itemsOnCanvas.values));

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
          buildMode: ItemBrowserBuildMode.sliver,
          onItemTapped: (ClothingItem item) {
            ref.read(outfitBuilderProvider.notifier).addItemToCanvas(item);
          },
          itemCounts: itemCounts,
        ),
      ],
    );
  }
}