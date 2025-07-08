// lib/screens/avatar_cropper_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// 1. Chuyển thành StatefulWidget
class AvatarCropperScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const AvatarCropperScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<AvatarCropperScreen> createState() => _AvatarCropperScreenState();
}

class _AvatarCropperScreenState extends State<AvatarCropperScreen> {
  // Biến để lưu tạm kết quả
  Uint8List? _croppedBytes;

  @override
  Widget build(BuildContext context) {
    return CropRotateEditor.memory(
      widget.imageBytes, // Sử dụng widget.imageBytes
      initConfigs: CropRotateEditorInitConfigs(
        theme: appTheme,
        convertToUint8List: true,
        callbacks: ProImageEditorCallbacks(
          // 2. Chỉ lưu kết quả, không pop màn hình
          onImageEditingComplete: (Uint8List bytes) async {
            _croppedBytes = bytes;
          },
          // 3. Chỉ pop màn hình ở đây, và trả về kết quả đã lưu
          onCloseEditor: (EditorMode mode) {
            if (context.mounted) {
              Navigator.of(context).pop(_croppedBytes);
            }
          },
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