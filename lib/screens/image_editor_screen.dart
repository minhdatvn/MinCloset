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
        // Callback này sẽ không được sử dụng trong luồng lưu của chúng ta nữa,
        // nhưng vẫn cần có để tránh lỗi.
        onImageEditingComplete: (Uint8List bytes) async {},
        
        // Callback khi người dùng muốn hủy bỏ
        onCloseEditor: (EditorMode mode) {
          Navigator.of(context).pop();
        },
      ),
      configs: ProImageEditorConfigs(
        theme: appTheme,
        // Tắt các tính năng không cần thiết
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
            // Cung cấp một AppBar tùy chỉnh, gọi đúng hàm của thư viện
            appBar: (editor, rebuildStream) {
              return ReactiveAppbar(
                stream: rebuildStream,
                builder: (_) => AppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close),
                    // Gọi hàm đóng mặc định của thư viện
                    onPressed: editor.closeEditor,
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Done',
                      icon: const Icon(Icons.done),
                      onPressed: () async {
                        // 1. Chỉ gọi hàm để lấy dữ liệu ảnh
                        final Uint8List? imageBytes = await editor.captureEditorImage();
                        
                        // 2. Tự quản lý việc pop và trả về dữ liệu
                        if (imageBytes != null && context.mounted) {
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