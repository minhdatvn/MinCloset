// lib/widgets/outfit_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
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
        _shareOutfit(context, ref, outfit);
      } else if (value == 'delete') {
        _deleteOutfit(context, ref, outfit, onUpdate);
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      // <<< THAY ĐỔI 1: Luôn cho phép "Rename" >>>
      const PopupMenuItem<String>(
        value: 'edit',
        // Đã xóa thuộc tính 'enabled' để nút luôn bật
        child: ListTile(
          leading: Icon(Icons.edit_outlined), // Icon luôn có màu mặc định
          title: Text('Rename'),
        ),
      ),
      const PopupMenuItem<String>(
        value: 'share',
        child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Share')),
      ),
      const PopupMenuDivider(),
      // <<< THAY ĐỔI 2: Luôn cho phép "Delete" >>>
      const PopupMenuItem<String>(
        value: 'delete',
        // Đã xóa thuộc tính 'enabled' để nút luôn bật
        child: ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red), // Icon luôn có màu đỏ
          title: Text('Delete', style: TextStyle(color: Colors.red)), // Chữ luôn có màu đỏ
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
        title: const Text('Rename outfit'),
        content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'New name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOutfit(BuildContext context, WidgetRef ref, Outfit outfit) async {
    // <<< SỬA LỖI: Lấy scaffoldMessenger ra trước khi có `await` >>>
    try {
      // ignore: deprecated_member_use_from_same_package, deprecated_member_use
      await Share.shareXFiles(
        [XFile(outfit.imagePath)],
        text: 'Let check out my outfit: "${outfit.name}"!',
      );
    } catch (e) {
      ref.read(notificationServiceProvider).showBanner(message: 'Could not share: $e'); // Thêm dòng này
    }
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref, Outfit outfit, VoidCallback? onUpdateCallback) async {
    // <<< SỬA LỖI: Lấy navigator và scaffoldMessenger ra trước khi có `await` >>>
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text('Permanently delete outfit "${outfit.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      )
    );

    // Thêm một bước kiểm tra `context.mounted` để an toàn tuyệt đối
    if (confirmed == true && context.mounted) {
      await ref.read(outfitDetailProvider(outfit).notifier).deleteOutfit();
      onUpdateCallback?.call();

      // Giờ đây việc sử dụng các biến này là an toàn
      // scaffoldMessenger.showSnackBar(SnackBar(content: Text('Đã xóa bộ đồ "${outfit.name}".'))); // Xóa dòng này
      ref.read(notificationServiceProvider).showBanner(
        message: 'Deleted outfit "${outfit.name}".',
        type: NotificationType.success,
      ); // Thêm dòng này

      if (navigator.canPop()) {
        navigator.pop(true);
      }
    }
  }
}