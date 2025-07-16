// lib/widgets/outfit_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/helpers/context_extensions.dart';
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
    final l10n = context.l10n;
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
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text(l10n.outfitMenu_rename),
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l10n.outfitMenu_share),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text(l10n.outfitMenu_delete, style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  void _showEditOutfitNameDialog(BuildContext context, WidgetRef ref, Outfit currentOutfit, VoidCallback? onUpdateCallback) {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: currentOutfit.name);
    showAnimatedDialog(
      context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.outfitMenu_rename_dialogTitle),
        content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.outfitMenu_rename_dialogLabel),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.common_cancel),
          ),
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
                      message: l10n.outfitMenu_rename_success,
                      type: NotificationType.success,
                    );
                onUpdateCallback?.call();
              }
              // Notifier đã tự log lỗi, ở đây UI không cần báo lỗi thất bại nữa

              navigator.pop();
            },
            child: Text(l10n.common_save),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOutfit(BuildContext context, WidgetRef ref, Outfit outfit) async {
    final l10n = context.l10n;
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(outfit.imagePath)],
          text: 'Let check out my outfit: "${outfit.name}"!',
        ),
      );
    } catch (e) {
      ref.read(notificationServiceProvider).showBanner(message: l10n.outfitMenu_share_error(e.toString()));
    }
  }

  Future<void> _deleteOutfit(BuildContext context, WidgetRef ref, Outfit outfit, VoidCallback? onUpdateCallback) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final notificationService = ref.read(notificationServiceProvider); // Lấy service ra trước

    final confirmed = await showAnimatedDialog<bool>(
      context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.outfitMenu_delete_dialogTitle),
        content: Text(l10n.outfitMenu_delete_dialogContent(outfit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.outfitMenu_delete),
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
              message: l10n.outfitMenu_delete_success(outfit.name),
              type: NotificationType.success,
            );
        if (navigator.canPop()) {
          navigator.pop(true);
        }
      } else {
        notificationService.showBanner(
              message: l10n.outfitMenu_delete_error,
            );
      }
    }
  }
}