// lib/screens/analysis_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/providers/service_providers.dart';

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
    final navigator = Navigator.of(context);

    // <<< Listener chỉ phản ứng với lỗi phân tích >>>
    ref.listen<BatchAddItemState>(batchAddItemProvider, (previous, next) async {
      if (!mounted) return;

      // Xử lý khi phân tích thành công
      if (next.analysisSuccess && previous?.analysisSuccess == false) {
        final analyzedItemArgs = ref.read(batchAddItemProvider).itemArgsList;
        bool? result;

        if (analyzedItemArgs.length == 1) {
          // Sử dụng pushNamed để mở AddItemScreen
          result = await navigator.pushNamed<bool>(
            AppRoutes.addItem,
            arguments: ItemNotifierArgs(
              tempId: analyzedItemArgs.first.tempId,
              preAnalyzedState: analyzedItemArgs.first.preAnalyzedState,
            ),
          );
        } else if (analyzedItemArgs.length > 1) {
          // Sử dụng pushNamed để mở BatchAddItemScreen
          result = await navigator.pushNamed<bool>(AppRoutes.batchAddItem);
        }
        if (mounted) { navigator.pop(result); }
      }
      
      // Xử lý khi chỉ có lỗi phân tích
      else if (next.analysisErrorMessage != null && previous?.analysisErrorMessage == null) {
        // Thay thế SnackBar ở đây
        ref.read(notificationServiceProvider).showBanner(
              message: 'Error analyzing item: ${next.analysisErrorMessage}',
            );
        navigator.pop(false);
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
                'Pre-filling item information...',
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