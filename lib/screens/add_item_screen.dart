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
      // Logic đã được đơn giản hóa, chỉ cần gọi notifier
      await ref.read(singleItemProvider(_providerArgs).notifier).deleteItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = singleItemProvider(_providerArgs);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    // <<< KHỐI LISTEN ĐỂ XỬ LÝ THÔNG BÁO VÀ ĐIỀU HƯỚNG >>>
    ref.listen<AddItemState>(provider, (previous, next) {
      if (next.successMessage != null) {
        ref.read(notificationServiceProvider).showBanner(
          message: next.successMessage!,
          type: NotificationType.success,
        );
        notifier.clearMessages(); // Xóa thông điệp để không hiển thị lại
        Navigator.of(context).pop(true); // Quay về và báo hiệu đã có thay đổi
      }
      if (next.errorMessage != null) {
        ref.read(notificationServiceProvider).showBanner(message: next.errorMessage!);
        notifier.clearMessages(); // Xóa thông điệp để không hiển thị lại
      }
    });

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
              onPressed: () {
                notifier.toggleFavorite();
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
        onEditImagePressed: () async {
          final navigator = Navigator.of(context);

          Uint8List? currentImageBytes;
          if (state.image != null) {
            currentImageBytes = await state.image!.readAsBytes();
          } else if (state.imagePath != null) {
            currentImageBytes = await File(state.imagePath!).readAsBytes();
          }

          if (currentImageBytes == null || !mounted) return;

          final editedBytes = await navigator.pushNamed<Uint8List?>(
            AppRoutes.imageEditor,
            arguments: currentImageBytes,
          );

          if (editedBytes != null && mounted) {
            notifier.updateImageWithBytes(editedBytes);
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: state.isLoading
              ? null
              : () async {
                  // Chỉ cần gọi notifier để lưu
                  await notifier.saveItem();
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