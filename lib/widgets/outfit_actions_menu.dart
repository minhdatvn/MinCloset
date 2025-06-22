// lib/widgets/outfit_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:share_plus/share_plus.dart';

class OutfitActionsMenu extends ConsumerWidget {
  final Outfit outfit;
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
        PopupMenuItem<String>(
          value: 'edit',
          enabled: !outfit.isFixed,
          child: ListTile(
            leading: Icon(Icons.edit_outlined, color: outfit.isFixed ? Colors.grey : null),
            title: const Text('Đổi tên'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Chia sẻ')),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          enabled: !outfit.isFixed,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: outfit.isFixed ? Colors.grey : Colors.red),
            title: Text('Xóa', style: TextStyle(color: outfit.isFixed ? Colors.grey : Colors.red)),
          ),
        ),
      ],
    );
  }

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
              // <<< SỬA LỖI: Lấy navigator ra trước khi có `await` >>>
              final navigator = Navigator.of(ctx);
              if (nameController.text.trim().isEmpty) return;

              await ref.read(outfitDetailProvider(currentOutfit).notifier).updateName(nameController.text.trim());
              
              onUpdateCallback?.call();
              // Giờ đây việc sử dụng `navigator` là an toàn
              navigator.pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOutfit(BuildContext context, Outfit outfit) async {
    // <<< SỬA LỖI: Lấy scaffoldMessenger ra trước khi có `await` >>>
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // ignore: deprecated_member_use_from_same_package
      await Share.shareXFiles(
        [XFile(outfit.imagePath)],
        text: 'Cùng xem bộ đồ "${outfit.name}" của tôi trên MinCloset nhé!',
      );
    } catch (e) {
      // Giờ đây việc sử dụng `scaffoldMessenger` là an toàn
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Không thể chia sẻ: $e')));
    }
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref, Outfit outfit, VoidCallback? onUpdateCallback) async {
    // <<< SỬA LỖI: Lấy navigator và scaffoldMessenger ra trước khi có `await` >>>
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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

    // Thêm một bước kiểm tra `context.mounted` để an toàn tuyệt đối
    if (confirmed == true && context.mounted) {
      await ref.read(outfitDetailProvider(outfit).notifier).deleteOutfit();
      onUpdateCallback?.call();
      
      // Giờ đây việc sử dụng các biến này là an toàn
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Đã xóa bộ đồ "${outfit.name}".')));
      if (navigator.canPop()) {
         navigator.pop(true);
      }
    }
  }
}