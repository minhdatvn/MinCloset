// lib/screens/outfit_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart'; // <<< THÊM IMPORT

class OutfitDetailPage extends ConsumerWidget {
  final Outfit outfit;

  const OutfitDetailPage({super.key, required this.outfit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = outfitDetailProvider(outfit);
    final currentOutfit = ref.watch(provider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(currentOutfit.name),
        // <<< THÊM NÚT MENU VÀO `actions`
        actions: [
          OutfitActionsMenu(
            outfit: currentOutfit,
            onUpdate: () {
              // Khi có cập nhật, báo cho trang trước đó (OutfitsHubPage)
              // bằng cách đánh dấu là có thay đổi.
              // Logic này cần được hoàn thiện thêm trong state của trang.
            },
          ),
        ],
      ),
      body: Center( // Đặt Center để ảnh không tràn hết màn hình
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.file(
            File(currentOutfit.imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}