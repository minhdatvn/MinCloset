// lib/screens/background_cropper_screen.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:mincloset/helpers/pro_image_editor_i18n_helper.dart';
import 'package:mincloset/helpers/context_extensions.dart';

class BackgroundCropperScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const BackgroundCropperScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<BackgroundCropperScreen> createState() =>
      _BackgroundCropperScreenState();
}

class _BackgroundCropperScreenState extends State<BackgroundCropperScreen> {
  Uint8List? _croppedBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ProImageEditor.memory(
      widget.imageBytes,
      callbacks: ProImageEditorCallbacks(
        // Dòng này đã được sửa, thêm `async`
        onImageEditingComplete: (Uint8List bytes) async {
          _croppedBytes = bytes;
        },
        onCloseEditor: (mode) {
          Navigator.of(context).pop(_croppedBytes);
        },
      ),
      configs: ProImageEditorConfigs(
        i18n: getProImageEditorI18n(l10n),
        theme: appTheme,
        cropRotateEditor: const CropRotateEditorConfigs(
          initAspectRatio: 3 / 4,
          showAspectRatioButton: false,
          showFlipButton: false,
          showRotateButton: false,
        ),
        paintEditor: const PaintEditorConfigs(enabled: false),
        textEditor: const TextEditorConfigs(enabled: false),
        filterEditor: const FilterEditorConfigs(enabled: false),
        blurEditor: const BlurEditorConfigs(enabled: false),
        emojiEditor: const EmojiEditorConfigs(enabled: false),
        stickerEditor: const StickerEditorConfigs(enabled: false),
      ),
    );
  }
}