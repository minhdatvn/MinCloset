// lib/screens/analysis_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/batch_add_item_state.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  final List<XFile> images;
  const AnalysisLoadingScreen({super.key, required this.images});

  @override
  ConsumerState<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(batchAddItemProvider.notifier).analyzeAllImages(widget.images);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // THAY ĐỔI: Chỉ lắng nghe `analysisSuccess`
    ref.listen<BatchAddItemState>(batchAddItemProvider, (previous, next) async {
      if (!mounted) return;

      // Khi quá trình phân tích hoàn tất (dù có dữ liệu hay không)
      if (next.analysisSuccess && previous?.analysisSuccess == false) {
        final analyzedItemArgs = ref.read(batchAddItemProvider).itemArgsList;
        final navigator = Navigator.of(context);
        bool? result;

        if (analyzedItemArgs.length == 1) {
          result = await navigator.pushNamed<bool>(
            AppRoutes.addItem,
            arguments: ItemNotifierArgs(
              tempId: analyzedItemArgs.first.tempId,
              preAnalyzedState: analyzedItemArgs.first.preAnalyzedState,
            ),
          );
        } else if (analyzedItemArgs.length > 1) {
          result = await navigator.pushNamed<bool>(AppRoutes.batchAddItem);
        }
        
        // Luôn pop màn hình loading sau khi màn hình nhập liệu được đóng
        if (mounted && navigator.canPop()) { 
          navigator.pop(result); 
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black.withAlpha((255 * 0.85).round()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              const SizedBox(height: 24),
              Text(
                'Analyzing images with AI...\nThis might take a moment.', // Thay đổi thông báo
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}