// lib/widgets/outfit_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:share_plus/share_plus.dart';

// Dùng ConsumerWidget để có thể truy cập `ref`
class OutfitActionsMenu extends ConsumerWidget {
  final Outfit outfit;
  // Thêm callback để báo hiệu cho trang cha khi có thay đổi (xóa/sửa)
  final VoidCallback? onUpdate;

  const OutfitActionsMenu({
    super.key,
    required this.outfit,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) {
        if (value == 'edit') {
          _showEditOutfitNameDialog(context, ref, outfit, onUpdate);
        } else if (value == 'share') {
          _shareOutfit(context, outfit);
        } else if (value == 'delete') {
          _deleteOutfit(context, ref, outfit, onUpdate);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Đổi tên')),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Chia sẻ')),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Xóa', style: TextStyle(color: Colors.red))),
        ),
      ],
    );
  }

  // Các hàm logic được đóng gói gọn gàng ở đây
  void _showEditOutfitNameDialog(BuildContext context, WidgetRef ref, Outfit currentOutfit, VoidCallback? onUpdateCallback) {
    final nameController = TextEditingController(text: currentOutfit.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên bộ đồ'),
        content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'Tên mới')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await ref.read(outfitDetailProvider(currentOutfit).notifier).updateName(nameController.text.trim());
              onUpdateCallback?.call(); // Gọi callback để trang cha cập nhật
              if (context.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOutfit(BuildContext context, Outfit outfit) async {
    try {
      await SharePlus.instance.share(ShareParams(
        text: 'Cùng xem bộ đồ "${outfit.name}" của tôi trên MinCloset nhé!',
        files: [XFile(outfit.imagePath)],
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể chia sẻ: $e')));
      }
    }
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref, Outfit outfit, VoidCallback? onUpdateCallback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn bộ đồ "${outfit.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      )
    );

    if (confirmed == true) {
      // <<< THAY ĐỔI Ở ĐÂY: Gọi đến notifier thay vì repository >>>
      await ref.read(outfitDetailProvider(outfit).notifier).deleteOutfit();
      onUpdateCallback?.call();
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa bộ đồ "${outfit.name}".')));
         // Nếu đang ở trang chi tiết, tự động quay về
         if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
         }
      }
    }
  }
}