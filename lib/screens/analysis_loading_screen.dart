// lib/screens/analysis_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/batch_add_item_screen.dart';
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
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // <<< Listener chỉ phản ứng với lỗi phân tích >>>
    ref.listen<BatchAddItemState>(batchAddItemProvider, (previous, next) async {
      if (!mounted) return;

      // Xử lý khi phân tích thành công
      if (next.analysisSuccess && previous?.analysisSuccess == false) {
        final analyzedItemArgs = ref.read(batchAddItemProvider).itemArgsList;
        bool? result;

        if (analyzedItemArgs.length == 1) {
          result = await navigator.push<bool>(MaterialPageRoute(builder: (context) => AddItemScreen(preAnalyzedState: analyzedItemArgs.first.preAnalyzedState)));
        } else if (analyzedItemArgs.length > 1) {
          result = await navigator.push<bool>(MaterialPageRoute(builder: (context) => const BatchAddItemScreen()));
        }
        if (mounted) { navigator.pop(result); }
      }
      
      // Xử lý khi chỉ có lỗi phân tích
      else if (next.analysisErrorMessage != null && previous?.analysisErrorMessage == null) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error analyzing item: ${next.analysisErrorMessage}')));
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
                'Pre-filling item information. You can edit later.',
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