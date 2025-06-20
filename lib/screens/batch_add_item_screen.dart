// lib/screens/batch_add_item_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart'; // <<< THÊM IMPORT CÒN THIẾU Ở ĐÂY
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
    final provider = batchAddItemProvider;
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    ref.listen<BatchAddItemState>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.saveSuccess) {
        Navigator.of(context).pop(true);
      }
      if (next.currentIndex != previous?.currentIndex && next.currentIndex != _pageController.page?.round()) {
        _pageController.animateToPage(
          next.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    if (state.itemStates.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Không có dữ liệu ảnh để hiển thị.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm món đồ (${state.currentIndex + 1}/${state.itemStates.length})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: state.itemStates.length,
              onPageChanged: notifier.setCurrentIndex,
              itemBuilder: (context, index) {
                final currentItemState = state.itemStates[index];
                return ItemDetailForm(
                  key: ValueKey('item_form_$index'),
                  itemState: currentItemState,
                  onNameChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(name: val)),
                  onClosetChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedClosetId: val)),
                  onCategoryChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedCategoryValue: val)),
                  onColorsChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedColors: val)),
                  onSeasonsChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedSeasons: val)),
                  onOccasionsChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedOccasions: val)),
                  onMaterialsChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedMaterials: val)),
                  onPatternsChanged: (val) => notifier.updateItemDetails(index, currentItemState.copyWith(selectedPatterns: val)),
                );
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
                if (state.currentIndex < state.itemStates.length - 1)
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