// lib/screens/pages/outfit_builder_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/screens/background_cropper_screen.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:uuid/uuid.dart';

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final ItemSearchFilterBar _searchBar;
  _SliverAppBarDelegate(this._searchBar);
  @override
  double get minExtent => 72.0;
  @override
  double get maxExtent => 72.0;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(242),
      child: _searchBar,
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class OutfitBuilderPage extends ConsumerStatefulWidget {
  final List<ClothingItem>? preselectedItems;
  final SuggestionResult? suggestionResult;

  const OutfitBuilderPage({
    super.key,
    this.preselectedItems,
    this.suggestionResult,
  });

  @override
  ConsumerState<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends ConsumerState<OutfitBuilderPage> {
  final _editorKey = GlobalKey<ProImageEditorState>();
  Uint8List? _imageData;
  final Map<String, ClothingItem> _itemsOnCanvas = {};
  bool _isSaving = false;
  static const _itemBrowserProviderId = 'outfit_builder_items';
  Map<String, int> _itemCountsOnCanvas = {};

  void _recalculateItemCounts() {
    final newCounts = <String, int>{};
    for (var item in _itemsOnCanvas.values) {
      newCounts[item.id] = (newCounts[item.id] ?? 0) + 1;
    }
    if (mounted) {
      setState(() {
        _itemCountsOnCanvas = newCounts;
      });
    }
  }
  // >>> THAY ĐỔI 2: VIẾT LẠI HOÀN TOÀN HÀM initState <<<
  @override
  @override
void initState() {
  super.initState();
  // Tạo một ảnh nền trắng trống để làm canvas
  _generateBlankImage(const Size(1000, 1000)).then((_) {
    // Đợi frame đầu tiên được vẽ xong để đảm bảo editor đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) async { // Chuyển thành hàm async
      if (!mounted) return;

      final editorState = _editorKey.currentState;
      if (editorState == null) return;

      // Chỉ thực hiện khi có dữ liệu suggestion được truyền vào
      if (widget.suggestionResult != null) {
        // --- BẮT ĐẦU LOGIC SẮP XẾP MỚI ---

        // 1. Định nghĩa trước các vị trí cho 5 loại item
        // Các tọa độ Offset này được tính từ TÂM của canvas
        final List<Offset> positions = [
          const Offset(0, -150),   // Vị trí cho áo khoác (trên cùng)
          const Offset(0, 0),      // Vị trí cho áo (ở giữa)
          const Offset(0, 150),    // Vị trí cho quần (phía dưới)
          const Offset(-100, 50),  // Vị trí cho giày (trái-dưới)
          const Offset(100, 50),   // Vị trí cho phụ kiện (phải-dưới)
        ];

        final composition = widget.suggestionResult!.composition;
        // 2. Xác định thứ tự ưu tiên để đặt item
        final slots = ['outerwear', 'topwear', 'bottomwear', 'footwear', 'accessories'];
        int positionIndex = 0;

        // 3. Lặp qua từng loại item và xử lý
        for (final slot in slots) {
          final item = composition[slot];

          // Nếu có item ở vị trí slot này
          if (item != null) {
            // Tạo một WidgetLayer đơn giản, không cần SizedBox hay offset ban đầu
            final layer = WidgetLayer(
              id: const Uuid().v4(),
              widget: Image.file(File(item.imagePath), fit: BoxFit.contain),
            );

            // Thêm layer vào editor (nó sẽ xuất hiện ở giữa)
            editorState.addLayer(layer, blockSelectLayer: true);

            // Đợi một khoảng rất ngắn để thư viện cập nhật trạng thái
            await Future.delayed(const Duration(milliseconds: 50));
            if (!mounted) return;

            // Lấy ra layer chúng ta vừa thêm (nó là layer cuối cùng trong danh sách)
            final addedLayer = editorState.activeLayers.last;

            // Di chuyển layer đó đến vị trí đã định sẵn
            if (positionIndex < positions.length) {
              addedLayer.offset = positions[positionIndex];
              positionIndex++;
            }

            // Lưu lại item này để dùng khi lưu bộ đồ
            _itemsOnCanvas[addedLayer.id] = item;
          }
        }

        // 4. Sau khi đã thêm và di chuyển tất cả, ra lệnh cho editor vẽ lại
        if (mounted) {
          editorState.setState(() {}); // Yêu cầu editor build lại với vị trí mới
          _recalculateItemCounts(); // Cập nhật lại số lượng item trên canvas
        }
        // --- KẾT THÚC LOGIC SẮP XẾP MỚI ---
      }
    });
  });
}

  Future<void> _generateBlankImage(Size size) async {
    final image = img.Image(width: 750, height: 1000);
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
      setState(() {
        _imageData = croppedBytes;
      });
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

    final result = await showAnimatedDialog<Map<String, dynamic>>(
      context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Form(
          key: formKey,
          child: AlertDialog(
            title: const Text('Save outfit'),
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
                          Text('Saving...'),
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
                      decoration: const InputDecoration(hintText: 'Example: Weekend coffee meet-up'),
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an outfit name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Fixed outfit', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Items in this outfit are always worn together. Each item can only belong to one fixed outfit.', style: TextStyle(fontSize: 12)),
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
                    : TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
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
                        child: const Text('Save'),
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
    return Material( // Thêm Material widget
      color: Theme.of(context).scaffoldBackgroundColor, // Đặt màu nền
      child: Padding(
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
                  tooltip: 'Undo',
                  onPressed: () => _editorKey.currentState?.undoAction(),
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo',
                  onPressed: () => _editorKey.currentState?.redoAction(),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
  
  Widget _buildItemBrowserSheet() {
    final notifier = ref.read(itemFilterProvider(_itemBrowserProviderId).notifier);
    final state = ref.watch(itemFilterProvider(_itemBrowserProviderId));

    return DraggableScrollableSheet(
      initialChildSize: 0.17,
      minChildSize: 0.07,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController scrollController) {
        void onScroll() {
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
              !state.isLoadingMore &&
              state.hasMore) {
            notifier.fetchMoreItems();
          }
        }
        scrollController.addListener(onScroll);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(38), blurRadius: 10)],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Container(
                      width: 40, height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(const ItemSearchFilterBar(providerId: _itemBrowserProviderId)),
              ),
              ItemBrowserView(
                providerId: _itemBrowserProviderId,
                onItemTapped: (item) {
                  final stickerId = const Uuid().v4();
                  _itemsOnCanvas[stickerId] = item;

                  _editorKey.currentState?.addLayer(
                    WidgetLayer(
                      id: stickerId,
                      widget:
                          Image.file(File(item.imagePath), fit: BoxFit.contain),
                      
                    ),
                  );
                  _recalculateItemCounts();
                },
                itemCounts: _itemCountsOnCanvas,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit studio'),
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
          // Lớp dưới cùng: Nền xám và Editor
          Column(
            children: [
              const SizedBox(height: 48), // Giữ khoảng trống cho toolbar
              Expanded(
                child: Container(
                  // 1. TẠO VÙNG ĐỆM MÀU XÁM
                  color: Colors.grey.shade200,
                  child: _imageData == null
                      ? const Center(child: CircularProgressIndicator())
                      : ProImageEditor.memory(
                          _imageData!,
                          key: _editorKey,
                          callbacks: ProImageEditorCallbacks(
                            mainEditorCallbacks: MainEditorCallbacks(
                              onRemoveLayer: (layer) {
                                // Khi một layer bị xóa khỏi editor,
                                // callback này sẽ được gọi.

                                // 1. Xóa item tương ứng khỏi map theo dõi của chúng ta
                                if (_itemsOnCanvas.containsKey(layer.id)) {
                                  _itemsOnCanvas.remove(layer.id);
                                }

                                // 2. Gọi hàm tính toán lại bộ đếm để cập nhật giao diện
                                _recalculateItemCounts();
                              },
                            ),
                            onImageEditingComplete: (_) async {},
                            onCloseEditor: (EditorMode mode) {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          configs: ProImageEditorConfigs(   
                            layerInteraction: const LayerInteractionConfigs(
                                selectable: LayerInteractionSelectable.enabled,
                                initialSelected: false,
                                icons: LayerInteractionIcons(
                                  remove: Icons.clear,
                                  edit: Icons.edit_outlined,
                                  rotateScale: Icons.sync,
                                ),
                              ),
                            mainEditor: MainEditorConfigs(
                              style: const MainEditorStyle(
                                  background: Colors.transparent),
                              widgets:
                                  MainEditorWidgets(appBar: (_, __) => null),
                            ),
                            textEditor: TextEditorConfigs(
                              showSelectFontStyleBottomBar: true,
                              customTextStyles: [
                                GoogleFonts.roboto(),
                                GoogleFonts.beVietnamPro(),
                                GoogleFonts.lora(),
                                GoogleFonts.montserrat(),
                                GoogleFonts.pacifico(),
                              ],
                            ),
                            stickerEditor: StickerEditorConfigs(
                              enabled: true,
                              builder: (setLayer, scrollController) {
                                return const Center(
                                  child: Text('Stickers will be available soon.'),
                                );
                              },
                            ),
                            cropRotateEditor:
                                const CropRotateEditorConfigs(enabled: false),
                            filterEditor:
                                const FilterEditorConfigs(enabled: false),
                            blurEditor: const BlurEditorConfigs(enabled: false),
                            tuneEditor: const TuneEditorConfigs(enabled: false),
                          ),
                        ),
                ),
              ),
            ],
          ),

          // Lớp trên cùng: Thanh công cụ "Change background"
          _buildSecondaryToolbar(),

          // Lớp trên cùng nhất: Thanh trượt vật phẩm (không thay đổi)
          Positioned(
            bottom: 57.0,
            left: 0,
            right: 0,
            top: 0,
            child: _buildItemBrowserSheet(),
          ),
        ],
      ),
    );
  }
}