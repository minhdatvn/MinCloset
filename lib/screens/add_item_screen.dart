// lib/screens/add_item_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:uuid/uuid.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final ClothingItem? itemToEdit;
  final AddItemState? preAnalyzedState;

  const AddItemScreen({
    super.key,
    this.itemToEdit,
    this.preAnalyzedState,
  });

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  late final String _tempId;
  late final ItemNotifierArgs _providerArgs;

  @override
  void initState() {
    super.initState();
    _tempId = widget.itemToEdit?.id ?? widget.preAnalyzedState?.id ?? const Uuid().v4();
    _providerArgs = ItemNotifierArgs(
      tempId: _tempId,
      itemToEdit: widget.itemToEdit,
      preAnalyzedState: widget.preAnalyzedState,
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    if (widget.itemToEdit == null) return;

    final confirmed = await showAnimatedDialog<bool>(
      context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text('Are you sure to permanently delete item "${widget.itemToEdit!.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Lấy navigator ra trước khi gọi await
      final notifier = ref.read(singleItemProvider(_providerArgs).notifier);
      final itemName = widget.itemToEdit!.name; // Lưu lại tên trước khi xóa
      final navigator = Navigator.of(context); // ignore: use_build_context_synchronously
      final notificationService = ref.read(notificationServiceProvider); // Lưu service

      final success = await notifier.deleteItem();
      
      if (!mounted) return;

      if (success) {
        // <<< Banner khi xóa thành công >>>
        notificationService.showBanner(
          message: 'Successfully deleted item "$itemName".',
          type: NotificationType.success,
        );
        navigator.pop(true);
      } else {
        // <<< Banner khi xóa thất bại >>>
        final errorMessage = ref.read(singleItemProvider(_providerArgs)).errorMessage;
        if (errorMessage != null) {
          notificationService.showBanner(message: errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = singleItemProvider(_providerArgs);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return PageScaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? 'Edit item' : 'Add item'),
        actions: [
          if (state.isEditing)
            IconButton(
              icon: Icon(
                state.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: state.isFavorite ? Colors.pink : null,
              ),
              // <<< THAY ĐỔI DUY NHẤT LÀ Ở HÀM onPressed NÀY >>>
              onPressed: () {
                // 1. Gọi hàm toggleFavorite trong notifier như bình thường
                notifier.toggleFavorite();
                
                // 2. Kích hoạt trigger ngay tại màn hình này.
                // Vì _AddItemScreenState là một ConsumerState, nó có quyền truy cập `ref`.
                ref.read(itemChangedTriggerProvider.notifier).state++;
              },
              tooltip: state.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
          
          if (state.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(context),
              tooltip: 'Delete item',
            ),
        ],
      ),
      body: ItemDetailForm(
        itemState: state,
        onNameChanged: notifier.onNameChanged,
        onClosetChanged: notifier.onClosetChanged,
        onCategoryChanged: notifier.onCategoryChanged,
        onColorsChanged: notifier.onColorsChanged,
        onSeasonsChanged: notifier.onSeasonsChanged,
        onOccasionsChanged: notifier.onOccasionsChanged,
        onMaterialsChanged: notifier.onMaterialsChanged,
        onPatternsChanged: notifier.onPatternsChanged,
        onPriceChanged: notifier.onPriceChanged,
        onNotesChanged: notifier.onNotesChanged,
        onImageUpdated: (newBytes) {
          notifier.updateImageWithBytes(newBytes);
        },
        // --- BẮT ĐẦU THÊM LOGIC VÀO ĐÂY ---
        onEditImagePressed: () async {
          // Lấy ra notifier và navigator TRƯỚC khi có await
          final notifier = ref.read(provider.notifier);
          final navigator = Navigator.of(context);

          Uint8List? currentImageBytes;
          if (state.image != null) {
            currentImageBytes = await state.image!.readAsBytes();
          } else if (state.imagePath != null) {
            currentImageBytes = await File(state.imagePath!).readAsBytes();
          }

          if (currentImageBytes == null || !mounted) return;

          // Sử dụng navigator đã được lấy ra từ trước, giờ đây nó an toàn
          final editedBytes = await navigator.pushNamed<Uint8List?>(
            AppRoutes.imageEditor,
            arguments: currentImageBytes,
          );

          if (editedBytes != null && mounted) {
            notifier.updateImageWithBytes(editedBytes);
          }
        },
        // --- KẾT THÚC THÊM LOGIC ---
      ),
      // <<< LUỒNG LƯU >>>
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
           onPressed: state.isLoading
              ? null
              : () async {
                  final notifier = ref.read(provider.notifier); // Lấy notifier
                  final success = await notifier.saveItem(); // Gọi hàm saveItem và chờ kết quả
                  
                  if (!mounted) return; // `mounted` check để đảm bảo widget vẫn còn tồn tại

                  if (success) { // Nếu thành công, quay về màn hình trước
                    final successMessage = state.isEditing // <<< Banner khi lưu/cập nhật thành công >>>
                      ? 'Item successfully updated.'
                      : 'Item successfully saved.';
                    ref.read(notificationServiceProvider).showBanner(
                          message: successMessage,
                          type: NotificationType.success,
                        );
                    Navigator.of(context).pop(true); // ignore: use_build_context_synchronously
                  } else {
                    final errorMessage = ref.read(provider).errorMessage; // Nếu thất bại, đọc lỗi từ state và hiển thị banner
                    if (errorMessage != null) {
                      ref.read(notificationServiceProvider).showBanner(message: errorMessage);
                    }
                  }
                },
          icon: state.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
          label: state.isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) 
              : const Text('Save'),
        ),
      ),
    );
  }
}