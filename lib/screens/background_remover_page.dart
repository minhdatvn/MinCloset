// lib/screens/background_remover_page.dart
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:mincloset/providers/service_providers.dart';

Future<Uint8List?> _removeBackgroundInIsolate(Uint8List imageBytes) async {
  await BackgroundRemover.instance.initializeOrt();
  final image = await BackgroundRemover.instance.removeBg(imageBytes);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  BackgroundRemover.instance.dispose();
  
  return byteData?.buffer.asUint8List();
}

class BackgroundRemoverPage extends ConsumerStatefulWidget {
  final Uint8List imageBytes;
  const BackgroundRemoverPage({super.key, required this.imageBytes});

  @override
  ConsumerState<BackgroundRemoverPage> createState() => _BackgroundRemoverPageState();
}

class _BackgroundRemoverPageState extends ConsumerState<BackgroundRemoverPage> {
  Uint8List? _removedBgImageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _processInBackground();
  }
  
  Future<void> _processInBackground() async {
    try {
      final resultBytes = await compute(_removeBackgroundInIsolate, widget.imageBytes);

      if (mounted) {
        setState(() {
          _removedBgImageBytes = resultBytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showBanner(
              message: 'Error removing background: $e',
            );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Background'),
        actions: [
          TextButton(
            onPressed: (_removedBgImageBytes == null || _isLoading)
                ? null
                : () {
                    Navigator.of(context).pop(_removedBgImageBytes);
                  },
            child: const Text('Done'),
          )
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  // DỊCH LẠI TRẠNG THÁI LOADING
                  Text('Processing, please wait...'),
                ],
              )
            : _removedBgImageBytes != null
                ? InteractiveViewer(child: Image.memory(_removedBgImageBytes!))
                : const Text('Could not process image.'),
      ),
    );
  }
}