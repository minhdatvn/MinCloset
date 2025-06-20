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
  ConsumerState<AnalysisLoadingScreen> createState() =>
      _AnalysisLoadingScreenState();
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
    // <<< THAY ĐỔI 1: Lấy ra Navigator và ScaffoldMessenger trước khi lắng nghe >>>
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    ref.listen<BatchAddItemState>(batchAddItemProvider, (previous, next) async {
      // Vẫn giữ kiểm tra `mounted` ở đầu để đảm bảo an toàn
      if (!mounted) return;

      if (next.analysisSuccess) {
        final analyzedStates = ref.read(batchAddItemProvider).itemStates;
        bool? result;

        if (analyzedStates.length == 1) {
          // <<< THAY ĐỔI 2: Sử dụng `navigator` đã được lấy ra trước đó >>>
          result = await navigator.push<bool>(
            MaterialPageRoute(
              builder: (context) => AddItemScreen(
                preAnalyzedState: analyzedStates.first,
              ),
            ),
          );
        } else if (analyzedStates.length > 1) {
          result = await navigator.push<bool>(
            MaterialPageRoute(
              builder: (context) => const BatchAddItemScreen(),
            ),
          );
        }

        if (mounted) {
          navigator.pop(result);
        }
      }
      
      else if (next.errorMessage != null && previous?.errorMessage == null) {
        // <<< THAY ĐỔI 3: Sử dụng `scaffoldMessenger` và `navigator` đã được lấy ra >>>
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi phân tích: ${next.errorMessage}')),
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                'A.I đang xem hình ảnh của bạn để nhập sẵn thông tin. Sau khi kết thúc bạn có thể tự chỉnh sửa.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}