// lib/screens/background_remover_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'dart:ui' as ui;

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
    _processOnMainThread();
  }
  
  // Không cần dispose() ở đây vì chúng ta sẽ hủy ngay trong hàm xử lý
  
  Future<void> _processOnMainThread() async {
    // Luôn đảm bảo setState được gọi trên một widget còn tồn tại
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // BƯỚC 1: Khởi tạo engine
      await BackgroundRemover.instance.initializeOrt();

      // BƯỚC 2: Chạy tác vụ xóa nền (sẽ làm treo UI)
      final image = await BackgroundRemover.instance.removeBg(widget.imageBytes);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      // BƯỚC 3: Hủy engine để giải phóng bộ nhớ
      BackgroundRemover.instance.dispose();

      if (mounted) {
        setState(() {
          _removedBgImageBytes = byteData?.buffer.asUint8List();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider).showBanner(
              message: 'Error processing image: $e',
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