// lib/screens/batch_add_item_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';
import 'package:mincloset/widgets/page_scaffold.dart';

class BatchItemDetailScreen extends ConsumerStatefulWidget {
  const BatchItemDetailScreen({super.key});
  @override
  ConsumerState<BatchItemDetailScreen> createState() => _BatchItemDetailScreenState();
}

class _BatchItemDetailScreenState extends ConsumerState<BatchItemDetailScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(batchAddScreenProvider).currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchAddScreenProvider);
    final notifier = ref.read(batchAddScreenProvider.notifier);
    final itemArgsList = state.itemArgsList;

    // <<< THAY ĐỔI LOGIC LISTENER ĐỂ MẠNH MẼ HƠN >>>
    ref.listen<BatchItemDetailState>(batchAddScreenProvider, (previous, next) {
      // 1. Xử lý thành công
      if (next.saveSuccess && previous?.saveSuccess == false) {
        // Chuyển MainScreen đến trang Closets (index = 1)
        ref.read(mainScreenIndexProvider.notifier).state = 1;

        // **DÒNG LỆNH MỚI: Chỉ định cho ClosetsPage hiển thị tab "All Items"**
        ref.read(closetsSubTabIndexProvider.notifier).state = 0;

        // Điều hướng về màn hình chính
        Navigator.of(context).pop(); 
        return; // Kết thúc để tránh xử lý các điều kiện khác
      }
      
      // 2. Xử lý hiển thị lỗi
      if (next.saveErrorMessage != null && next.saveErrorMessage != previous?.saveErrorMessage) {
        ref.read(notificationServiceProvider).showBanner(message: next.saveErrorMessage!);
      }

      // 3. Xử lý đồng bộ PageController (luôn chạy khi index thay đổi)
      if (previous != null && next.currentIndex != previous.currentIndex) {
        if (_pageController.hasClients && _pageController.page?.round() != next.currentIndex) {
          _pageController.animateToPage(
            next.currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    if (itemArgsList.isEmpty) {
      return const Scaffold(body: Center(child: Text('No photos to display.')));
    }

    return PageScaffold(
      appBar: AppBar(title: Text('Add item (${state.currentIndex + 1}/${itemArgsList.length})')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: itemArgsList.length,
              onPageChanged: notifier.setCurrentIndex, // Người dùng vuốt tay
              itemBuilder: (context, index) {
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
                  label: const Text('Previous'),              
                ),
                if (state.currentIndex < itemArgsList.length - 1)
                  // Nút "Sau" giờ sẽ gọi hàm nextPage đã có validation
                  ElevatedButton.icon(onPressed: notifier.nextPage, icon: const Icon(Icons.arrow_forward), label: const Text('Next'))
                else
                  ElevatedButton.icon(
                    onPressed: state.isSaving ? null : notifier.saveAll,
                    icon: state.isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: const Text('Save all'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ItemFormPage không thay đổi
class ItemFormPage extends ConsumerWidget {
  final ItemDetailNotifierArgs providerArgs;
  const ItemFormPage({super.key, required this.providerArgs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemState = ref.watch(batchItemFormProvider(providerArgs));
    final itemNotifier = ref.read(batchItemFormProvider(providerArgs).notifier);

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
      onPriceChanged: itemNotifier.onPriceChanged,
      onNotesChanged: itemNotifier.onNotesChanged,
      onImageUpdated: (newBytes) {
        itemNotifier.updateImageWithBytes(newBytes);
      },
      onEditImagePressed: () async {
        final navigator = Navigator.of(context);

        // Lấy dữ liệu byte của ảnh hiện tại
        Uint8List? currentImageBytes;
        if (itemState.image != null) {
          currentImageBytes = await itemState.image!.readAsBytes();
        } else if (itemState.imagePath != null) {
          currentImageBytes = await File(itemState.imagePath!).readAsBytes();
        }

        if (currentImageBytes == null || !context.mounted) return;

        // Điều hướng đến màn hình chỉnh sửa và chờ kết quả
        final editedBytes = await navigator.pushNamed<Uint8List?>(
          AppRoutes.imageEditor,
          arguments: currentImageBytes,
        );

        // Nếu có ảnh đã sửa trả về, cập nhật state
        if (editedBytes != null && context.mounted) {
          itemNotifier.updateImageWithBytes(editedBytes);
        }
      },
    );
  }
}