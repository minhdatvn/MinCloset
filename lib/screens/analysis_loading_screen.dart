// lib/screens/analysis_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/notifiers/batch_add_item_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  // --- THAY ĐỔI 1: Thay đổi constructor để nhận ImageSource ---
  final ImageSource source; 
  const AnalysisLoadingScreen({super.key, required this.source});

  @override
  ConsumerState<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // --- THAY ĐỔI 2: Gọi hàm mới để bắt đầu quy trình ---
        _triggerImagePickingAndAnalysis();
      }
    });
  }

  // --- THAY ĐỔI 3: Tạo hàm mới xử lý việc chọn ảnh ---
  Future<void> _triggerImagePickingAndAnalysis() async {
    final imagePicker = ImagePicker();
    List<XFile> pickedFiles = [];

    try {
      if (widget.source == ImageSource.gallery) {
          pickedFiles = await imagePicker.pickMultiImage(
            maxWidth: 1024,
            imageQuality: 85,
          );
      } else {
          final singleFile = await imagePicker.pickImage(
              source: ImageSource.camera, 
              maxWidth: 1024, 
              imageQuality: 85
          );
          if (singleFile != null) {
              pickedFiles.add(singleFile);
          }
      }
    } catch (e) {
      logger.e("Lỗi khi chọn ảnh", error: e);
      if(mounted) {
        Navigator.of(context).pop();
      }
      return;
    }


    if (!mounted) return;

    if (pickedFiles.isEmpty) {
      logger.i("Người dùng đã hủy chọn ảnh.");
      Navigator.of(context).pop();
      return; 
    }
    
    // Nếu có ảnh, bắt đầu phân tích
    _startAnalysis(pickedFiles);
  }

  // --- THAY ĐỔI 4: Xóa hàm _startImagePickingAndAnalysis cũ ---
  // Future<void> _startImagePickingAndAnalysis() async { ... } // XÓA HÀM NÀY

  // Hàm _startAnalysis giờ đã đơn giản hơn
  Future<void> _startAnalysis(List<XFile> files) async {
    List<XFile> filesToProcess = files;
    if (files.length > 10) {
      filesToProcess = files.take(10).toList();
      if (mounted) {
        ref.read(notificationServiceProvider).showBanner(
              message: context.l10n.analysis_maxPhotosWarning,
              type: NotificationType.warning,
            );
      }
    }

    // Luồng này bây giờ là an toàn vì màn hình đã hiển thị
    ref.read(batchAddScreenProvider.notifier).prepareForAnalysis(filesToProcess.length);
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      ref.read(batchAddScreenProvider.notifier).analyzeAllImages(filesToProcess);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phần build giữ nguyên vì nó chỉ phụ thuộc vào state của notifier
    // ...
    final stage = ref.watch(batchAddScreenProvider.select((s) => s.stage));
    final loadingMessage = stage == AnalysisStage.preparing 
        ? context.l10n.analysis_preparingImages 
        : context.l10n.analysis_prefillingInfo;
    
    // Lắng nghe điều hướng (giữ nguyên)
    ref.listen<BatchItemDetailState>(batchAddScreenProvider, (previous, next) {
      if (!mounted) return;
      if (next.analysisSuccess && previous?.analysisSuccess == false) {
        final analyzedItemArgs = ref.read(batchAddScreenProvider).itemArgsList;
        final navigator = Navigator.of(context);

        if (analyzedItemArgs.length == 1) {
          navigator.pushReplacementNamed(
            AppRoutes.addItem,
            arguments: ItemDetailNotifierArgs(
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                loadingMessage,
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