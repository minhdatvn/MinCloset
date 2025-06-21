// lib/screens/add_item_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
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

  // <<< THAY ĐỔI 4: XÓA BỎ HOÀN TOÀN PHƯƠNG THỨC `dispose` GÂY LỖI >>>
  /*
  @override
  void dispose() {
    // Dọn dẹp trạng thái của notifier khi màn hình bị hủy.
    // Dùng Future.microtask để đảm bảo nó được gọi sau khi quá trình build hoàn tất.
    Future.microtask(() {
      ref.read(addItemProvider(_providerArgs).notifier).resetState();
    });
    super.dispose();
  }
  */

  void _showImageSourceActionSheet(BuildContext context) {
    final notifier = ref.read(addItemProvider(_providerArgs).notifier);
    
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

  // <<< THAY ĐỔI 5: CẬP NHẬT LUỒNG XÓA >>>
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    if (widget.itemToEdit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn món đồ "${widget.itemToEdit!.name}" không?'),
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
      // Lấy navigator ra trước khi gọi await
      // ignore: use_build_context_synchronously
      final navigator = Navigator.of(context);
      final success = await ref.read(addItemProvider(_providerArgs).notifier).deleteItem();
      
      // Nếu xóa thành công và widget vẫn còn tồn tại, hãy pop màn hình
      if (success && mounted) {
        navigator.pop(true);
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
    
    // <<< THAY ĐỔI 6: XÓA LUỒNG LẮNG NGHE `isSuccess` >>>
    ref.listen<AddItemState>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      // if (next.isSuccess) {
      //   Navigator.of(context).pop(true);
      // }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? 'Sửa món đồ' : 'Thêm đồ mới'),
        actions: [
          if (state.isEditing || state.image == null)
            IconButton(
              icon: const Icon(Icons.add_a_photo_outlined),
              onPressed: () => _showImageSourceActionSheet(context),
              tooltip: 'Chọn ảnh khác',
            ),
          if (state.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(context),
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
      // <<< THAY ĐỔI 7: CẬP NHẬT LUỒNG LƯU >>>
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: state.isLoading
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  final success = await notifier.saveItem();
                  if (success && mounted) {
                    navigator.pop(true);
                  }
                },
          icon: state.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
          label: state.isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) 
              : Text(state.isEditing ? 'Cập nhật' : 'Lưu'),
        ),
      ),
    );
  }
}