// lib/screens/outfit_detail_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/widgets/outfit_actions_menu.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class OutfitDetailPage extends ConsumerStatefulWidget {
  final Outfit outfit;
  const OutfitDetailPage({super.key, required this.outfit});

  @override
  ConsumerState<OutfitDetailPage> createState() => _OutfitDetailPageState();
}

class _OutfitDetailPageState extends ConsumerState<OutfitDetailPage> {

  @override
  Widget build(BuildContext context) {
    final provider = outfitDetailProvider(widget.outfit);
    final currentOutfit = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = context.l10n; 
    
    return PageScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(currentOutfit.name),
        actions: [
          OutfitActionsMenu(
            outfit: currentOutfit,
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
                title: Text(l10n.outfitDetail_fixedOutfit_title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.outfitDetail_fixedOutfit_description),
                value: currentOutfit.isFixed,
                onChanged: (newValue) async {
                  final errorMessage = await notifier.toggleIsFixed(newValue);
                  if (errorMessage != null) {
                    ref
                        .read(notificationServiceProvider)
                        .showBanner(message: errorMessage);
                  }
                  // Không cần setState nữa vì state của outfit đã được cập nhật trong notifier
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}