// lib/screens/analysis_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/utils/logger.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  // Tham số này là optional, chỉ dùng cho trường hợp chụp ảnh từ camera
  final List<XFile>? images; 
  const AnalysisLoadingScreen({super.key, this.images});

  @override
  ConsumerState<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {
  String _loadingMessage = "Preparing images...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Nếu có ảnh được truyền vào (từ camera), thì phân tích ngay
        if (widget.images != null && widget.images!.isNotEmpty) {
          _startAnalysis(widget.images!);
        } else {
          // Nếu không, bắt đầu quy trình chọn ảnh từ album
          _startImagePickingAndAnalysis();
        }
      }
    });
  }

  // Hàm dành cho việc chọn ảnh từ album
  Future<void> _startImagePickingAndAnalysis() async {
    final imagePicker = ImagePicker();
    final pickedFiles = await imagePicker.pickMultiImage(
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (!mounted) return;

    if (pickedFiles.isEmpty) {
      logger.i("Image picking cancelled by user.");
      Navigator.of(context).pop();
      return; 
    }
    
    _startAnalysis(pickedFiles);
  }

  // Hàm chung để bắt đầu phân tích
  void _startAnalysis(List<XFile> files) {
    setState(() {
      _loadingMessage = "Pre-filling information...\nThis may take a moment to complete.";
    });

    List<XFile> filesToProcess = files;
    if (files.length > 10) {
      filesToProcess = files.take(10).toList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 10 photos selected. Extra photos were skipped.')),
      );
    }
    
    ref.read(batchAddItemProvider.notifier).analyzeAllImages(filesToProcess);
  }

  @override
  Widget build(BuildContext context) {
    // <<< THAY ĐỔI: Giờ chúng ta sẽ watch toàn bộ state >>>
    final batchState = ref.watch(batchAddItemProvider);
    
    // Lắng nghe để điều hướng
    ref.listen<BatchAddItemState>(batchAddItemProvider, (previous, next) {
      if (!mounted) return;
      if (next.analysisSuccess && previous?.analysisSuccess == false) {
        final analyzedItemArgs = ref.read(batchAddItemProvider).itemArgsList;
        final navigator = Navigator.of(context);

        if (analyzedItemArgs.length == 1) {
          navigator.pushReplacementNamed(
            AppRoutes.addItem,
            arguments: ItemNotifierArgs(
              tempId: analyzedItemArgs.first.tempId,
              preAnalyzedState: analyzedItemArgs.first.preAnalyzedState,
            ),
          );
        } else if (analyzedItemArgs.length > 1) {
          navigator.pushReplacementNamed(AppRoutes.batchAddItem);
        } else {
          navigator.pop();
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha:0.85),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // <<< THAY ĐỔI: Hiển thị thanh tiến độ hoặc vòng xoay tùy giai đoạn >>>
              if (batchState.stage == AnalysisStage.analyzing && batchState.totalItemsToProcess > 0)
                // Giai đoạn 2: Hiển thị thanh tiến độ
                _CustomProgressBar(
                  value: batchState.itemsProcessed / batchState.totalItemsToProcess,
                )
              else
                // Giai đoạn 1 (mặc định): Hiển thị vòng xoay vô định
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
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

// <<< Widget thanh tiến độ tùy chỉnh >>>
class _CustomProgressBar extends StatelessWidget {
  final double value; // Giá trị từ 0.0 đến 1.0

  const _CustomProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 12, // Tăng chiều cao thanh
        backgroundColor: Colors.white.withValues(alpha:0.2),
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
      ),
    );
  }
}