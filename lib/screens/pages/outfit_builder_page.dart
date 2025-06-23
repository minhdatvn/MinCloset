// lib/screens/pages/outfit_builder_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:mincloset/screens/background_cropper_screen.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generateBlankImage(const Size(750, 1000));
  }

  Future<void> _generateBlankImage(Size size) async {
    final image = img.Image(width: size.width.toInt(), height: size.height.toInt());
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    if (mounted) {
      setState(() {
        _imageData = Uint8List.fromList(img.encodePng(image));
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || !mounted) return;

    final imageBytes = await pickedFile.readAsBytes();

    if (!mounted) return;

    final croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (context) => BackgroundCropperScreen(imageBytes: imageBytes),
      ),
    );

    if (croppedBytes != null && mounted) {
      // BƯỚC 1: Cập nhật state của parent widget (OutfitBuilderPage)
      // để đảm bảo các lần build lại trong tương lai sử dụng đúng ảnh.
      setState(() {
        _imageData = croppedBytes;
      });

      // BƯỚC 2: Ra lệnh cho State HIỆN TẠI của ProImageEditor
      // cập nhật ngay lập tức hình nền của nó.
      _editorKey.currentState
          ?.updateBackgroundImage(EditorImage(byteArray: croppedBytes));
    }
  }

  Future<void> _showSaveDialog(Uint8List editedImageBytes) async {
    if (!mounted) return;
    final nameController = TextEditingController();
    bool isFixed = false;
    final isSavingNotifier = ValueNotifier<bool>(false);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Form(
          key: formKey,
          child: AlertDialog(
            title: const Text('Lưu bộ đồ'),
            content: ValueListenableBuilder<bool>(
              valueListenable: isSavingNotifier,
              builder: (context, isSaving, child) {
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Ví dụ: Cà phê cuối tuần'),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên cho bộ đồ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Bộ đồ cố định', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Các món đồ sẽ luôn được gợi ý cùng nhau.', style: TextStyle(fontSize: 12)),
                      value: isFixed,
                      onChanged: (newValue) => setState(() => isFixed = newValue),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                );
              },
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: isSavingNotifier,
                builder: (context, isSaving, _) => isSaving
                    ? const SizedBox.shrink()
                    : TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isSavingNotifier,
                builder: (context, isSaving, _) => isSaving
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.of(ctx).pop({'name': nameController.text.trim(), 'isFixed': isFixed});
                          }
                        },
                        child: const Text('Lưu'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      isSavingNotifier.value = true;
      final navigator = Navigator.of(context);
      await ref.read(outfitBuilderProvider.notifier).saveOutfit(
            name: result['name'] as String,
            isFixed: result['isFixed'] as bool,
            itemsOnCanvas: _itemsOnCanvas,
            capturedImage: editedImageBytes,
          );
      if (mounted && navigator.canPop()) navigator.pop();
    }
  }

  Widget _buildSecondaryToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Change background'),
            onPressed: _pickBackgroundImage,
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Hoàn tác',
                onPressed: () => _editorKey.currentState?.undoAction(),
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Làm lại',
                onPressed: () => _editorKey.currentState?.redoAction(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemBrowserSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.17,
      minChildSize: 0.07,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(242),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Tay nắm kéo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              // Thanh tìm kiếm và bộ lọc
              const ItemSearchFilterBar(providerId: 'outfit_builder_items'),
              // Danh sách vật phẩm
              ItemBrowserView(
                providerId: 'outfit_builder_items',
                onItemTapped: (item) {
                  final stickerId = const Uuid().v4();
                  _itemsOnCanvas[stickerId] = item;
                  _editorKey.currentState?.addLayer(
                    WidgetLayer(widget: Image.file(File(item.imagePath), fit: BoxFit.contain), id: stickerId),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OutfitBuilderState>(outfitBuilderProvider, (previous, next) {
      if (next.saveSuccess && !(previous?.saveSuccess ?? false)) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Đã lưu bộ đồ thành công!')));
        Navigator.of(context).pop(true);
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Builder'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _editorKey.currentState?.closeEditor()),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))),
            )
          else
            TextButton(
              onPressed: () async {
                setState(() => _isSaving = true);
                final Uint8List? bytes = await _editorKey.currentState?.captureEditorImage();
                setState(() => _isSaving = false);
                if (bytes != null && mounted) {
                  await _showSaveDialog(bytes);
                }
              },
              child: Text('Save', style: Theme.of(context).appBarTheme.titleTextStyle),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Lớp dưới: Trình chỉnh sửa chính
          Column(
            children: [
              _buildSecondaryToolbar(),
              const Divider(height: 1),
              Expanded(
                child: _imageData == null
                    ? const Center(child: CircularProgressIndicator())
                    : ProImageEditor.memory(
                        _imageData!,
                        key: _editorKey,
                        callbacks: ProImageEditorCallbacks(
                          onImageEditingComplete: (_) async {},
                          onCloseEditor: (EditorMode mode) {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        configs: ProImageEditorConfigs(
                          mainEditor: MainEditorConfigs(
                            style: const MainEditorStyle(background: Colors.white),
                            widgets: MainEditorWidgets(appBar: (_, __) => null),
                          ),
                          stickerEditor: const StickerEditorConfigs(enabled: false),
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            // Ghim nó vào các cạnh trái, phải và dưới, nhưng cách cạnh dưới 80px
            bottom: 60.0,
            left: 0,
            right: 0,
            // Cho phép nó chiếm toàn bộ chiều cao còn lại phía trên
            top: 0, 
            child: _buildItemBrowserSheet(),
          ),
        ],
      ),
    );
  }
}