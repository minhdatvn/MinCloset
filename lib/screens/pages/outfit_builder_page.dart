// lib/screens/pages/outfit_builder_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/screens/background_cropper_screen.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
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

  @override
  void initState() {
    super.initState();
    _generateBlankImage(const Size(750, 1000)).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (widget.suggestionResult != null) {
          _addLayersFromSuggestion(widget.suggestionResult!);
        } else if (widget.preselectedItems != null) {
          _addLayersFromPreselection(widget.preselectedItems!);
        }
      });
    });
  }

  // >>> THAY ĐỔI 1: TÁCH LOGIC THÊM LAYER RA HÀM RIÊNG <<<
  void _addLayersFromSuggestion(SuggestionResult result) {
    final List<ClothingItem> itemsToAdd = result.composition.values.where((item) => item != null).cast<ClothingItem>().toList();
    
    // Các giá trị để xếp tầng các vật phẩm
    double initialX = 30.0;
    double initialY = 50.0;
    double yOffsetStep = 60.0; // Khoảng cách giữa các lớp theo chiều dọc

    for (int i = 0; i < itemsToAdd.length; i++) {
      final item = itemsToAdd[i];
      final stickerId = const Uuid().v4();
      _itemsOnCanvas[stickerId] = item;
      
      // Tính toán vị trí xếp tầng
      final position = Offset(initialX, initialY + (i * yOffsetStep));
      
      _editorKey.currentState?.addLayer(
        WidgetLayer(
          id: stickerId,
          offset: position, // Gán vị trí đã tính toán
          widget: SizedBox(
            width: 250, // Kích thước đồng nhất ban đầu
            height: 250,
            child: Image.file(File(item.imagePath), fit: BoxFit.contain),
          ),
        ),
      );
    }

    _recalculateItemCounts();
  }

  void _addLayersFromPreselection(List<ClothingItem> items) {
    double initialX = 30.0;
    double initialY = 50.0;
    double yOffsetStep = 60.0;

    for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final stickerId = const Uuid().v4();
        _itemsOnCanvas[stickerId] = item;
        final position = Offset(initialX, initialY + (i * yOffsetStep));
        _editorKey.currentState?.addLayer(
            WidgetLayer(
              id: stickerId,
              offset: position,
              widget: SizedBox(
                  width: 250,
                  height: 250,
                  child: Image.file(File(item.imagePath), fit: BoxFit.contain),
              ),
            ),
        );
    }
    _recalculateItemCounts();
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

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
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
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(242),
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
                  
                  // >>> THAY ĐỔI 2: ĐƠN GIẢN HÓA LOGIC THÊM THỦ CÔNG <<<
                  // Chỉ cần thêm layer, không cần vị trí và kích thước
                  _editorKey.currentState?.addLayer(
                    WidgetLayer(
                      id: stickerId,
                      widget: Image.file(File(item.imagePath), fit: BoxFit.contain),
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
    ref.listen<OutfitBuilderState>(outfitBuilderProvider, (previous, next) {
      if (next.saveSuccess && !(previous?.saveSuccess ?? false)) {
        ref.read(notificationServiceProvider).showBanner(
          message: 'Outfit saved successfully!',
          type: NotificationType.success,
        );
        Navigator.of(context).pop(true);
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ref.read(notificationServiceProvider).showBanner(message: next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Studio'),
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
                          stickerEditor: StickerEditorConfigs(
                            enabled: true,
                            builder: (setLayer, scrollController) {
                              return const Center(
                                child: Text('Stickers will be available soon.'),
                              );
                            },
                          ),
                          cropRotateEditor: const CropRotateEditorConfigs(enabled: false),
                          filterEditor: const FilterEditorConfigs(enabled: false),
                          blurEditor: const BlurEditorConfigs(enabled: false),
                          tuneEditor: const TuneEditorConfigs(enabled: false),
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 60.0,
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