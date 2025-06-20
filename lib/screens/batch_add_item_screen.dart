// lib/screens/batch_add_item_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';

class BatchAddItemScreen extends ConsumerStatefulWidget {
  const BatchAddItemScreen({super.key});

  @override
  ConsumerState<BatchAddItemScreen> createState() => _BatchAddItemScreenState();
}

class _BatchAddItemScreenState extends ConsumerState<BatchAddItemScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(batchAddItemProvider).currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchAddItemProvider);
    final notifier = ref.read(batchAddItemProvider.notifier);
    // <<< THAY ĐỔI: Lấy ra danh sách args
    final itemArgsList = state.itemArgsList;

    ref.listen<BatchAddItemState>(batchAddItemProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.saveSuccess) {
        Navigator.of(context).pop(true);
      }
      if (previous?.currentIndex != next.currentIndex && next.currentIndex != _pageController.page?.round()) {
        _pageController.animateToPage(
          next.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    if (itemArgsList.isEmpty) {
      return const Scaffold(body: Center(child: Text('Không có dữ liệu ảnh để hiển thị.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm món đồ (${state.currentIndex + 1}/${itemArgsList.length})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: itemArgsList.length,
              onPageChanged: notifier.setCurrentIndex,
              itemBuilder: (context, index) {
                // <<< THAY ĐỔI: Lấy ra args tại vị trí index
                final itemArgs = itemArgsList[index];
                return ItemFormPage(key: ValueKey(itemArgs.tempId), providerArgs: itemArgs);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: state.currentIndex > 0 ? notifier.previousPage : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Trước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  )
                ),
                if (state.currentIndex < itemArgsList.length - 1)
                  ElevatedButton.icon(
                    onPressed: notifier.nextPage,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Sau'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: state.isSaving ? null : notifier.saveAll,
                    icon: state.isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: const Text('Lưu tất cả'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItemFormPage extends ConsumerWidget {
  // <<< THAY ĐỔI: Nhận vào một đối tượng ItemNotifierArgs
  final ItemNotifierArgs providerArgs;
  const ItemFormPage({super.key, required this.providerArgs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // <<< THAY ĐỔI: Sử dụng trực tiếp providerArgs nhận được
    final itemState = ref.watch(addItemProvider(providerArgs));
    final itemNotifier = ref.read(addItemProvider(providerArgs).notifier);

    return ItemDetailForm(
      itemState: itemState,
      onNameChanged: itemNotifier.onNameChanged,
      onClosetChanged: itemNotifier.onClosetChanged,
      onCategoryChanged: itemNotifier.onCategoryChanged,
      onColorsChanged: itemNotifier.onColorsChanged,
      onSeasonsChanged: itemNotifier.onSeasonsChanged,
      onOccasionsChanged: itemNotifier.onOccasionsChanged,
      onMaterialsChanged: itemNotifier.onMaterialsChanged,
      onPatternsChanged: itemNotifier.onPatternsChanged,
    );
  }
}