// lib/screens/add_item_screen.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart'; // <<< THÊM IMPORT THIẾU
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/widgets/item_detail_form.dart';

// <<< BƯỚC 1: TẠO LỚP ARGS ĐỂ ĐÓNG GÓI THAM SỐ
@immutable
class AddItemScreenArgs extends Equatable {
  final ClothingItem? itemToEdit;
  final XFile? newImage;

  const AddItemScreenArgs({this.itemToEdit, this.newImage});

  @override
  List<Object?> get props => [itemToEdit, newImage];
}

// <<< BƯỚC 2: ĐỊNH NGHĨA LẠI PROVIDER CHO ĐÚNG
final addItemProvider = StateNotifierProvider.autoDispose
    .family<AddItemNotifier, AddItemState, AddItemScreenArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  return AddItemNotifier(clothingItemRepo, args);
});


class AddItemScreen extends ConsumerWidget {
  final String? preselectedClosetId;
  final ClothingItem? itemToEdit;
  final XFile? newImage;

  const AddItemScreen({
    super.key,
    this.preselectedClosetId,
    this.itemToEdit,
    this.newImage,
  });

  void _showImageSourceActionSheet(BuildContext context, WidgetRef ref) {
    // Tạo args để truyền vào provider khi gọi notifier
    final args = AddItemScreenArgs(itemToEdit: itemToEdit, newImage: newImage);
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
                notifier.pickImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                notifier.pickImage(ImageSource.camera);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) async {
    if (itemToEdit == null) return;
    final args = AddItemScreenArgs(itemToEdit: itemToEdit, newImage: newImage);

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
    // <<< BƯỚC 3: SỬA LẠI CÁCH GỌI PROVIDER
    final args = AddItemScreenArgs(itemToEdit: itemToEdit, newImage: newImage);
    final provider = addItemProvider(args);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (itemToEdit == null && preselectedClosetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.onClosetChanged(preselectedClosetId);
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
          if (!state.isEditing)
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
          label: state.isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(state.isEditing ? 'Cập nhật' : 'Lưu'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
        ),
      ),
    );
  }
}