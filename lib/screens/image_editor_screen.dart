// lib/screens/image_editor_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mincloset/theme/app_theme.dart'; // Sử dụng theme của bạn
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditorScreen extends StatefulWidget {
  // Màn hình này sẽ nhận dữ liệu ảnh (dưới dạng bytes) từ màn hình trước
  final Uint8List imageBytes;

  const ImageEditorScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Uint8List? _editedBytes;

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      widget.imageBytes,
      callbacks: ProImageEditorCallbacks(
        // Khi người dùng nhấn nút "Done", ảnh đã chỉnh sửa sẽ được trả về
        onImageEditingComplete: (Uint8List bytes) async {
          setState(() {
            _editedBytes = bytes;
          });
          Navigator.of(context).pop(_editedBytes);
        },
        // Nếu người dùng đóng editor mà không lưu
        onCloseEditor: (mode) {
          Navigator.of(context).pop();
        },
      ),
      configs: ProImageEditorConfigs(
        theme: appTheme, // Áp dụng theme chung của ứng dụng
        // CẤU HÌNH CÁC TÍNH NĂNG THEO YÊU CẦU
        cropRotateEditor: const CropRotateEditorConfigs(
          enabled: true, // Bật Crop/Rotate
        ),
        filterEditor: const FilterEditorConfigs(
          enabled: true, // Bật Filter
        ),
        tuneEditor: const TuneEditorConfigs(
          enabled: true, // Bật Tune
        ),
        // TẮT TẤT CẢ CÁC TÍNH NĂNG KHÁC
        paintEditor: const PaintEditorConfigs(enabled: false),
        textEditor: const TextEditorConfigs(enabled: false),
        blurEditor: const BlurEditorConfigs(enabled: false),
        emojiEditor: const EmojiEditorConfigs(enabled: false),
        stickerEditor: const StickerEditorConfigs(enabled: false),
      ),
    );
  }
}