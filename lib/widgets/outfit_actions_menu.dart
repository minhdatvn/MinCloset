// lib/widgets/outfit_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
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
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Rename'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Share')),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  void _showEditOutfitNameDialog(BuildContext context, WidgetRef ref, Outfit currentOutfit, VoidCallback? onUpdateCallback) {
    final nameController = TextEditingController(text: currentOutfit.name);
    showAnimatedDialog(
      context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename outfit'),
        content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'New name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              if (nameController.text.trim().isEmpty) return;

              // 1. Chờ kết quả từ notifier
              final bool success = await ref
                  .read(outfitDetailProvider(currentOutfit).notifier)
                  .updateName(nameController.text.trim());
              
              // 2. Nếu thành công, hiển thị banner và gọi callback
              if (success) {
                ref.read(notificationServiceProvider).showBanner(
                      message: 'Outfit name updated.',
                      type: NotificationType.success,
                    );
                onUpdateCallback?.call();
              }
              // Notifier đã tự log lỗi, ở đây UI không cần báo lỗi thất bại nữa

              navigator.pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOutfit(BuildContext context, WidgetRef ref, Outfit outfit) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(outfit.imagePath)],
          text: 'Let check out my outfit: "${outfit.name}"!',
        ),
      );
    } catch (e) {
      ref.read(notificationServiceProvider).showBanner(message: 'Could not share: $e');
    }
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref, Outfit outfit, VoidCallback? onUpdateCallback) async {
    final navigator = Navigator.of(context);
    final notificationService = ref.read(notificationServiceProvider); // Lấy service ra trước

    final confirmed = await showAnimatedDialog<bool>(
      context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: Text('Permanently delete outfit "${outfit.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      )
    );

    if (confirmed == true && context.mounted) {
      final bool success =
          await ref.read(outfitDetailProvider(outfit).notifier).deleteOutfit();

      if (success) {
        onUpdateCallback?.call();
        notificationService.showBanner(
              message: 'Deleted outfit "${outfit.name}".',
              type: NotificationType.success,
            );
        if (navigator.canPop()) {
          navigator.pop(true);
        }
      } else {
        notificationService.showBanner(
              message: 'Failed to delete outfit. Please try again.',
            );
      }
    }
  }
}