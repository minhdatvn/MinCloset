// lib/screens/add_item_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/item_detail_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:uuid/uuid.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final ClothingItem? itemToEdit;
  final ItemDetailState? preAnalyzedState;

  const ItemDetailScreen({
    super.key,
    this.itemToEdit,
    this.preAnalyzedState,
  });

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late final String _tempId;
  late final ItemDetailNotifierArgs _providerArgs;

  @override
  void initState() {
    super.initState();
    _tempId = widget.itemToEdit?.id ?? widget.preAnalyzedState?.id ?? const Uuid().v4();
    _providerArgs = ItemDetailNotifierArgs(
      tempId: _tempId,
      itemToEdit: widget.itemToEdit,
      preAnalyzedState: widget.preAnalyzedState,
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    if (widget.itemToEdit == null) return;
    final l10n = context.l10n;

    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: l10n.itemDetail_deleteDialogTitle,
      content: Text(l10n.itemDetail_deleteDialogContent(widget.itemToEdit!.name)),
    );

    if (confirmed == true) {
      // Logic đã được đơn giản hóa, chỉ cần gọi notifier
      await ref.read(itemDetailProvider(_providerArgs).notifier).deleteItem(l10n: l10n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = itemDetailProvider(_providerArgs);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = context.l10n;

    // <<< KHỐI LISTEN ĐỂ XỬ LÝ THÔNG BÁO VÀ ĐIỀU HƯỚNG >>>
    ref.listen<String?>(itemDetailErrorProvider, (previous, next) {
      if (next != null) {
        ref.read(notificationServiceProvider).showBanner(message: next);
        // Reset kênh ngay lập tức để sẵn sàng cho lỗi tiếp theo
        ref.read(itemDetailErrorProvider.notifier).state = null;
      }
    });

    // Lắng nghe trạng thái của form để xử lý thành công và điều hướng
    ref.listen<ItemDetailState>(provider, (previous, next) {
      if (!mounted) return;
      // Khi có thông báo thành công (đã lưu xong)
      if (next.successMessage != null && previous?.successMessage == null) {
        ref.read(notificationServiceProvider).showBanner(
          message: next.successMessage!,
          type: NotificationType.success,
        );
        if (!next.isEditing) {
          ref.read(mainScreenIndexProvider.notifier).state = 1;
          ref.read(closetsSubTabIndexProvider.notifier).state = 0;
        }
        Navigator.of(context).pop(true);
      }
      // Xử lý các lỗi hệ thống (không phải lỗi nhập liệu)
      if (next.errorMessage != null && previous?.errorMessage == null) {
        ref.read(notificationServiceProvider).showBanner(message: next.errorMessage!);
        notifier.clearMessages(); // Vẫn xóa lỗi hệ thống khỏi state chính
      }
    });

    return PageScaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? l10n.itemDetail_titleEdit : l10n.itemDetail_titleAdd),
        actions: [
          if (state.isEditing)
            IconButton(
              icon: Icon(
                state.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: state.isFavorite ? Colors.pink : null,
              ),
              onPressed: () {
                ref.read(itemDetailProvider(_providerArgs).notifier).toggleFavorite();
                ref.read(itemChangedTriggerProvider.notifier).state++;
              },
              tooltip: state.isFavorite ? l10n.itemDetail_favoriteTooltip_remove : l10n.itemDetail_favoriteTooltip_add,
            ),
          
          if (state.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(context),
              tooltip: l10n.itemDetail_deleteTooltip,
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
          notifier.updateImageWithBytes(newBytes, l10n: l10n);
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
            notifier.updateImageWithBytes(editedBytes, l10n: l10n);
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
                  await notifier.saveItem(l10n: context.l10n);
                },
          icon: state.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
          label: state.isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) 
              : Text(l10n.itemDetail_saveButton),
        ),
      ),
    );
  }
}