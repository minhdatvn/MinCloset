// lib/screens/avatar_cropper_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:mincloset/helpers/pro_image_editor_i18n_helper.dart';
import 'package:mincloset/helpers/context_extensions.dart';

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
  Uint8List? _croppedBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CropRotateEditor.memory(
      widget.imageBytes,
      initConfigs: CropRotateEditorInitConfigs(
        // 1. Cung cấp `theme` trực tiếp vì nó là tham số bắt buộc.
        theme: appTheme,
        convertToUint8List: true,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            _croppedBytes = bytes;
          },
          onCloseEditor: (EditorMode mode) {
            if (context.mounted) {
              Navigator.of(context).pop(_croppedBytes);
            }
          },
        ),
        // 2. Cung cấp đối tượng `ProImageEditorConfigs` cho thuộc tính `configs`.
        //    Đây là nơi chứa `i18n` và các cấu hình chi tiết khác.
        configs: ProImageEditorConfigs(
          i18n: getProImageEditorI18n(l10n),
          cropRotateEditor: const CropRotateEditorConfigs(
            initialCropMode: CropMode.oval,
            initAspectRatio: 1.0,
          ),
        ),
      ),
    );
  }
}