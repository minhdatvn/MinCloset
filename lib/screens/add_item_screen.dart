// lib/screens/add_item_screen.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';


@immutable
class AddItemScreenArgs extends Equatable {
  final ClothingItem? itemToEdit;
  final XFile? newImage;
  final AddItemState? preAnalyzedState; 

  const AddItemScreenArgs({this.itemToEdit, this.newImage, this.preAnalyzedState});

  @override
  List<Object?> get props => [itemToEdit, newImage, preAnalyzedState];
}

final addItemProvider = StateNotifierProvider.autoDispose
    .family<AddItemNotifier, AddItemState, AddItemScreenArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  return AddItemNotifier(clothingItemRepo, ref, args);
});

class AddItemScreen extends ConsumerWidget {
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

  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    final args = AddItemScreenArgs(itemToEdit: itemToEdit, newImage: newImage, preAnalyzedState: preAnalyzedState);
    final notifier = ref.read(addItemProvider(args).notifier);
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ Album'),
              onTap: () {
                Navigator.of(ctx).pop();
                notifier.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
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

  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) async {
    if (itemToEdit == null) return;
    final args = AddItemScreenArgs(itemToEdit: itemToEdit, newImage: newImage, preAnalyzedState: preAnalyzedState);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn món đồ "${itemToEdit!.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(addItemProvider(args).notifier).deleteItem();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = AddItemScreenArgs(
        itemToEdit: itemToEdit,
        newImage: newImage,
        preAnalyzedState: preAnalyzedState,
    );
    final provider = addItemProvider(args);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (itemToEdit == null && preselectedClosetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(provider).selectedClosetId == null) {
          notifier.onClosetChanged(preselectedClosetId);
        }
      });
    }
    
    ref.listen<AddItemState>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.isSuccess) {
        Navigator.of(context).pop(true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? 'Sửa món đồ' : 'Thêm đồ mới'),
        actions: [
          if (state.isEditing || state.image == null)
            IconButton(
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => _showImageSourceActionSheet(context, ref),
              tooltip: 'Chọn ảnh khác',
            ),
          if (state.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(context, ref),
              tooltip: 'Xóa món đồ',
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: state.isLoading ? null : notifier.saveItem,
          icon: state.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
          label: state.isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) 
              : Text(state.isEditing ? 'Cập nhật' : 'Lưu'),
          // <<< ĐÃ XÓA BỎ STYLE CỤC BỘ Ở ĐÂY >>>
        ),
      ),
    );
  }
}