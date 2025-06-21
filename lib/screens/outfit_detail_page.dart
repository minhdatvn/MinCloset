// lib/screens/outfit_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart';

class OutfitDetailPage extends ConsumerWidget {
  final Outfit outfit;

  const OutfitDetailPage({super.key, required this.outfit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = outfitDetailProvider(outfit);
    final currentOutfit = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(currentOutfit.name),
        actions: [
          OutfitActionsMenu(outfit: currentOutfit),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.file(
                File(currentOutfit.imagePath),
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SwitchListTile(
                title: const Text('Bộ đồ cố định', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Các món đồ trong bộ này sẽ luôn được gợi ý cùng nhau.'),
                value: currentOutfit.isFixed,
                // <<< CẬP NHẬT LOGIC onChanged >>>
                onChanged: (newValue) async {
                  // Hàm toggleIsFixed giờ trả về một String? (thông báo lỗi)
                  final errorMessage = await notifier.toggleIsFixed(newValue);
                  
                  // Nếu có lỗi, hiển thị SnackBar
                  if (errorMessage != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      )
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}