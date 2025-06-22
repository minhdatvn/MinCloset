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

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Save Outfit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(hintText: 'E.g., Weekend coffee date'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Fixed Outfit', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Items will always be suggested together.', style: TextStyle(fontSize: 12)),
                    value: isFixed,
                    onChanged: (newValue) => setState(() => isFixed = newValue),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      Navigator.of(ctx).pop({
                        'name': nameController.text.trim(),
                        'isFixed': isFixed,
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      await ref.read(outfitBuilderProvider.notifier).saveOutfit(
            name: result['name'] as String,
            isFixed: result['isFixed'] as bool,
            itemsOnCanvas: _itemsOnCanvas,
            capturedImage: editedImageBytes,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OutfitBuilderState>(outfitBuilderProvider, (previous, next) {
      if (next.saveSuccess && !(previous?.saveSuccess ?? false)) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Outfit saved successfully!')));
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Workshop'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _editorKey.currentState?.closeEditor();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Change Background',
            onPressed: _pickBackgroundImage,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Outfit',
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
              // <<< SỬA LỖI: Đặt các hàm callback vào đúng đối tượng ProImageEditorCallbacks >>>
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
                // Cấu hình cho tính năng Crop & Rotate
                cropRotateEditorConfigs: const CropRotateEditorConfigs(
                  // Cung cấp danh sách các tỷ lệ
                  aspectRatioOptions: [
                    CropAspectRatio(text: 'Outfit', ratio: 3 / 4),
                  ],
                ),
                // Cấu hình cho Filter - Tắt đi
                filterEditorConfigs: const FilterEditorConfigs(enabled: false),
                // Cấu hình cho Blur - Tắt đi
                blurEditorConfigs: const BlurEditorConfigs(enabled: false),

                // Cấu hình cho Sticker
                stickerEditorConfigs: StickerEditorConfigs(
                  // Sử dụng builder để truyền hàm `setLayer`
                  builder: (context, setLayer, scrollCtrl) {
                    final outfitBuilderState = ref.watch(outfitBuilderProvider);
                    if (outfitBuilderState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GridView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                widget: Image.file(File(item.imagePath), fit: BoxFit.contain),
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