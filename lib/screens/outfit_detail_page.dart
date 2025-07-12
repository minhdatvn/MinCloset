// lib/screens/outfit_detail_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart';
import 'package:mincloset/widgets/page_scaffold.dart';

class OutfitDetailPage extends ConsumerStatefulWidget {
  final Outfit outfit;
  const OutfitDetailPage({super.key, required this.outfit});

  @override
  ConsumerState<OutfitDetailPage> createState() => _OutfitDetailPageState();
}

class _OutfitDetailPageState extends ConsumerState<OutfitDetailPage> {
  bool _didChange = false;

  @override
  Widget build(BuildContext context) {
    final provider = outfitDetailProvider(widget.outfit);
    final currentOutfit = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.of(context).pop(_didChange);
        }
      },
      child: PageScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(currentOutfit.name),
          actions: [
            OutfitActionsMenu(
              outfit: currentOutfit,
              onUpdate: () => setState(() => _didChange = true),
            ),
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
                  title: const Text('Fixed outfit', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Items in this outfit are always worn together. Each item can only belong to one fixed outfit.'),
                  value: currentOutfit.isFixed,
                  onChanged: (newValue) async {
                    final errorMessage = await notifier.toggleIsFixed(newValue);
                    if (errorMessage == null) {
                      setState(() => _didChange = true);
                    } else {
                      ref
                          .read(notificationServiceProvider)
                          .showBanner(message: errorMessage);
                    }
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}