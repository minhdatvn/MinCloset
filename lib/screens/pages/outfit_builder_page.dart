// lib/screens/pages/outfit_builder_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/widgets/recent_item_card.dart';
// Import chính của thư viện và các model cần thiết
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:uuid/uuid.dart';

class OutfitBuilderPage extends ConsumerStatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  ConsumerState<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends ConsumerState<OutfitBuilderPage> {
  final _editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? _imageData;
  final Map<String, ClothingItem> _itemsOnCanvas = {};

  @override
  void initState() {
    super.initState();
    _generateBlankImage(const Size(750, 1000));
  }

  Future<void> _generateBlankImage(Size size) async {
    final image = img.Image(
      width: size.width.toInt(),
      height: size.height.toInt(),
      backgroundColor: img.ColorRgb8(255, 255, 255),
    );
    if (mounted) {
      setState(() {
        _imageData = Uint8List.fromList(img.encodePng(image));
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageData = bytes;
      });
    }
  }

  Future<void> _showSaveDialog(Uint8List editedImageBytes) async {
  if (!mounted) return;

  final nameController = TextEditingController();
  bool isFixed = false;
  // <<< THÊM VALUE NOTIFIER ĐỂ KIỂM SOÁT NÚT LƯU >>>
  final isSavingNotifier = ValueNotifier<bool>(false);

  // Dùng để kiểm tra xem nút lưu có nên được bật hay không
  final formKey = GlobalKey<FormState>();

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    // Ngăn người dùng bấm ra ngoài để đóng dialog khi đang lưu
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Form( // Bọc trong Form để validate
            key: formKey,
            child: AlertDialog(
              title: const Text('Lưu bộ đồ'),
              content: ValueListenableBuilder<bool>(
                // Lắng nghe trạng thái đang lưu
                valueListenable: isSavingNotifier,
                builder: (context, isSaving, child) {
                  // Nếu đang lưu thì hiển thị loading
                  if (isSaving) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Đang lưu...'),
                          ],
                        ),
                      ),
                    );
                  }
                  // Ngược lại, hiển thị form
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            hintText: 'Ví dụ: Cà phê cuối tuần'),
                        autofocus: true,
                        // Validator để đảm bảo tên không bị trống
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên cho bộ đồ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Bộ đồ cố định',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                            'Các món đồ sẽ luôn được gợi ý cùng nhau.',
                            style: TextStyle(fontSize: 12)),
                        value: isFixed,
                        onChanged: (newValue) =>
                            setState(() => isFixed = newValue),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                },
              ),
              actions: [
                // <<< HIỂN THỊ NÚT HỦY KHI KHÔNG LƯU >>>
                ValueListenableBuilder<bool>(
                  valueListenable: isSavingNotifier,
                  builder: (context, isSaving, _) => isSaving
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Hủy')),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isSavingNotifier,
                  builder: (context, isSaving, _) => isSaving
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                          onPressed: () {
                            // Validate form trước khi lưu
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.of(ctx).pop({
                                'name': nameController.text.trim(),
                                'isFixed': isFixed,
                              });
                            }
                          },
                          child: const Text('Lưu'),
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (result != null && mounted) {
    // Báo cho dialog biết là đang lưu
    isSavingNotifier.value = true;
    await ref.read(outfitBuilderProvider.notifier).saveOutfit(
          name: result['name'] as String,
          isFixed: result['isFixed'] as bool,
          itemsOnCanvas: _itemsOnCanvas,
          capturedImage: editedImageBytes,
        );
    // Sau khi lưu xong, tắt dialog
    if (mounted) Navigator.of(context).pop();
  }
}

  @override
Widget build(BuildContext context) {
  // <<< CẬP NHẬT LISTENER ĐỂ ĐÓNG MÀN HÌNH KHI LƯU THÀNH CÔNG >>>
  ref.listen<OutfitBuilderState>(outfitBuilderProvider, (previous, next) {
    // Nếu lưu thành công, hiển thị thông báo và đóng màn hình editor
    if (next.saveSuccess && !(previous?.saveSuccess ?? false)) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Đã lưu bộ đồ thành công!')));
      // Trả về true để màn hình trước có thể tải lại danh sách
      Navigator.of(context).pop(true);
    }
    // Nếu có lỗi, chỉ hiển thị thông báo
    if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: Colors.red,
        ));
    }
  });

  return Scaffold(
      appBar: AppBar(
        title: const Text('Xưởng phối đồ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _editorKey.currentState?.closeEditor();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Đổi ảnh nền',
            onPressed: _pickBackgroundImage,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Lưu bộ đồ',
            onPressed: () {
              _editorKey.currentState?.doneEditing();
            },
          ),
        ],
      ),
      body: _imageData == null
          ? const Center(child: CircularProgressIndicator())
          : ProImageEditor.memory(
              _imageData!,
              key: _editorKey,
              callbacks: ProImageEditorCallbacks(
                onImageEditingComplete: (Uint8List bytes) async {
                  await _showSaveDialog(bytes);
                },
                onCloseEditor: (EditorMode mode) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              configs: ProImageEditorConfigs(
                //... các config khác giữ nguyên
                cropRotateEditor: const CropRotateEditorConfigs(
                  aspectRatios: [
                    AspectRatioItem(text: 'Outfit', value: 3 / 4),
                  ],
                ),
                filterEditor: const FilterEditorConfigs(enabled: false),
                blurEditor: const BlurEditorConfigs(enabled: false),
                stickerEditor: StickerEditorConfigs(
                  enabled: true,
                  builder: (setLayer, scrollCtrl) {
                    final outfitBuilderState = ref.watch(outfitBuilderProvider);
                    if (outfitBuilderState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GridView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: outfitBuilderState.allItems.length,
                      itemBuilder: (context, index) {
                        final item = outfitBuilderState.allItems[index];
                        return GestureDetector(
                          onTap: () {
                            final stickerId = const Uuid().v4();
                            _itemsOnCanvas[stickerId] = item;
                            setLayer(
                              WidgetLayer(
                                widget: Image.file(File(item.imagePath),
                                    fit: BoxFit.contain),
                                id: stickerId,
                              ),
                            );
                          },
                          child: RecentItemCard(item: item),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}