// lib/screens/image_editor_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mincloset/theme/app_theme.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditorScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const ImageEditorScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      imageBytes,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {},
        onCloseEditor: (EditorMode mode) {
          Navigator.of(context).pop();
        },
      ),
      configs: ProImageEditorConfigs(
        theme: appTheme,
        cropRotateEditor: const CropRotateEditorConfigs(enabled: true),
        filterEditor: const FilterEditorConfigs(enabled: true),
        tuneEditor: const TuneEditorConfigs(enabled: true),
        paintEditor: const PaintEditorConfigs(enabled: false),
        textEditor: const TextEditorConfigs(enabled: false),
        blurEditor: const BlurEditorConfigs(enabled: false),
        emojiEditor: const EmojiEditorConfigs(enabled: false),
        stickerEditor: const StickerEditorConfigs(enabled: false),
        mainEditor: MainEditorConfigs(
          widgets: MainEditorWidgets(
            appBar: (editor, rebuildStream) {
              return ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => AppBar(
                  title: const Text('Edit image'),
                  backgroundColor: Colors.black, 
                  foregroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close),
                    onPressed: editor.closeEditor,
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Done',
                      icon: const Icon(Icons.done),
                      onPressed: () async {
                        // 1. Sửa kiểu dữ liệu thành non-nullable: Uint8List
                        final Uint8List imageBytes = await editor.captureEditorImage();
                        
                        // 2. Kiểm tra xem ảnh có dữ liệu không (thay vì kiểm tra null)
                        if (imageBytes.isNotEmpty && context.mounted) {
                          Navigator.of(context).pop(imageBytes);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}