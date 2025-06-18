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
    
    return Scaffold(
      backgroundColor: Colors.white, // <<< THAY ĐỔI Ở ĐÂY
      appBar: AppBar(
        title: Text(currentOutfit.name),
        actions: [
          OutfitActionsMenu(
            outfit: currentOutfit,
            onUpdate: () {
            },
          ),
        ],
      ),
      body: Center(
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