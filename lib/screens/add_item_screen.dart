// lib/screens/add_item_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';
import 'package:uuid/uuid.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final String? preselectedClosetId;
  final ClothingItem? itemToEdit;
  final XFile? newImage;
  final AddItemState? preAnalyzedState;

  const AddItemScreen({
    super.key,
    this.preselectedClosetId,
    this.itemToEdit,
    this.newImage,
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
      newImage: widget.newImage,
      preAnalyzedState: widget.preAnalyzedState,
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final notifier = ref.read(addItemProvider(_providerArgs).notifier);
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('From album'),
              onTap: () {
                Navigator.of(ctx).pop();
                notifier.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                notifier.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    if (widget.itemToEdit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
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
      final notifier = ref.read(addItemProvider(_providerArgs).notifier);
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
        final errorMessage = ref.read(addItemProvider(_providerArgs)).errorMessage;
        if (errorMessage != null) {
          notificationService.showBanner(message: errorMessage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = addItemProvider(_providerArgs);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (widget.itemToEdit == null && widget.preselectedClosetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(provider).selectedClosetId == null) {
          notifier.onClosetChanged(widget.preselectedClosetId);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? 'Edit item' : 'Add item'),
        // <<< BẮT ĐẦU THAY THẾ TỪ ĐÂY >>>
        actions: [
          // 1. Chỉ hiện nút "Thêm ảnh" khi TẠO MỚI và CHƯA CÓ ẢNH
          if (!state.isEditing && state.image == null)
            IconButton(
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => _showImageSourceActionSheet(context),
              tooltip: 'Add a photo',
            ),

          // 2. Chỉ hiện nút "Favorite" khi SỬA
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