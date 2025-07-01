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
           // Trường hợp không có ảnh nào để xử lý, đóng lại
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