// lib/screens/avatar_cropper_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class AvatarCropperScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const AvatarCropperScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return CropRotateEditor.memory(
      imageBytes,
      initConfigs: CropRotateEditorInitConfigs(
        theme: appTheme,
        convertToUint8List: true,
        
        callbacks: ProImageEditorCallbacks(
          // --- SỬA LỖI CHÍNH XÁC TẠI ĐÂY ---
          // 1. Thêm lại từ khóa `async` để có đúng kiểu trả về Future<void>
          onImageEditingComplete: (Uint8List bytes) async {
            if (context.mounted) {
              Navigator.of(context).pop(bytes);
            }
          },
          
          // 2. Giữ nguyên chữ ký hàm đúng cho onCloseEditor
          onCloseEditor: (EditorMode mode) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          // --- KẾT THÚC SỬA LỖI ---
        ),
        
        configs: const ProImageEditorConfigs(
          cropRotateEditor: CropRotateEditorConfigs(
            initialCropMode: CropMode.oval,
            initAspectRatio: 1.0,
          ),
        ),
      ),
    );
  }
}