// lib/screens/pages/outfit_builder_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/notifiers/item_filter_notifier.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/screens/background_cropper_screen.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/widgets/item_browser_view.dart';
import 'package:mincloset/widgets/item_search_filter_bar.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:uuid/uuid.dart';
import 'package:mincloset/widgets/persistent_header_delegate.dart';
import 'package:mincloset/helpers/pro_image_editor_i18n_helper.dart';

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
    _generateBlankImage(const Size(1000, 1000)).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async { 
        if (!mounted) return;

        final editorState = _editorKey.currentState;
        if (editorState == null) return;

        // Xử lý suggestionResult
        if (widget.suggestionResult != null) {
          final List<Offset> positions = [ const Offset(0, -150), const Offset(0, 0), const Offset(0, 150), const Offset(-100, 50), const Offset(100, 50) ];
          final composition = widget.suggestionResult!.composition;
          final slots = ['outerwear', 'topwear', 'bottomwear', 'footwear', 'accessories'];
          int positionIndex = 0;
          for (final slot in slots) {
            final item = composition[slot];
            if (item != null) {
              final layer = WidgetLayer(id: const Uuid().v4(), widget: Image.file(File(item.imagePath), fit: BoxFit.contain));
              editorState.addLayer(layer, blockSelectLayer: true);
              await Future.delayed(const Duration(milliseconds: 50));
              if (!mounted) return;
              final addedLayer = editorState.activeLayers.last;
              if (positionIndex < positions.length) {
                addedLayer.offset = positions[positionIndex];
                positionIndex++;
              }
              _itemsOnCanvas[addedLayer.id] = item;
            }
          }
          if (mounted) {
            editorState.setState(() {}); 
            _recalculateItemCounts(); 
          }
        } 
        // Xử lý preselectedItems
        else if (widget.preselectedItems != null) {
          for (final item in widget.preselectedItems!) {
            final stickerId = const Uuid().v4();
            _itemsOnCanvas[stickerId] = item;
            editorState.addLayer(WidgetLayer(id: stickerId, widget: Image.file(File(item.imagePath), fit: BoxFit.contain)));
          }
          _recalculateItemCounts();
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
      _editorKey.currentState?.updateBackgroundImage(EditorImage(byteArray: croppedBytes));
    }
  }
  
  // Các hàm build helper khác không đổi
  Widget _buildSecondaryToolbar() {
    return Material( 
      color: Theme.of(context).scaffoldBackgroundColor, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(context.l10n.outfitBuilder_changeBg_button),
              onPressed: _pickBackgroundImage,
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.undo), tooltip: context.l10n.outfitBuilder_undo_tooltip, onPressed: () => _editorKey.currentState?.undoAction()),
                IconButton(icon: const Icon(Icons.redo), tooltip: context.l10n.outfitBuilder_redo_tooltip, onPressed: () => _editorKey.currentState?.redoAction()),
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
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 && !state.isLoadingMore && state.hasMore) {
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
                  child: Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: PersistentHeaderDelegate( // Sử dụng delegate chung mà chúng ta đã tạo
                  child: ItemSearchFilterBar( // Bỏ const
                    providerId: _itemBrowserProviderId,
                    onApplyFilter: notifier.applyFilters,
                    activeFilters: ref.watch(itemFilterProvider(_itemBrowserProviderId)).activeFilters,
                  ),
                ),
              ),
              ItemBrowserView(
                providerId: _itemBrowserProviderId,
                onItemTapped: (item) {
                  final stickerId = const Uuid().v4();
                  _itemsOnCanvas[stickerId] = item;
                  _editorKey.currentState?.addLayer(WidgetLayer(id: stickerId, widget: Image.file(File(item.imagePath), fit: BoxFit.contain)));
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
    //ref.listen để xử lý điều hướng
    ref.listen<OutfitBuilderState>(outfitBuilderProvider, (previous, next) {
      // Khi cờ saveSuccess chuyển từ false -> true
      if (next.saveSuccess && previous?.saveSuccess == false) {
        ref.read(notificationServiceProvider).showBanner(
          message: context.l10n.outfitBuilder_save_success,
          type: NotificationType.success,
        );
        // Pop màn hình và trả về true
        ref.read(mainScreenIndexProvider.notifier).state = 2;
        Navigator.of(context).pop(); 
      }

      // Hiển thị lỗi nếu có
      if (next.errorMessage != null && previous?.errorMessage == null) {
        // Thay thế ScaffoldMessenger bằng NotificationService
        ref.read(notificationServiceProvider).showBanner(
              message: next.errorMessage!,
              // Mặc định là NotificationType.error nên không cần truyền
            );
      }
    });

    return PageScaffold(
      appBar: AppBar(
        title: Text(context.l10n.outfitBuilder_title),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(false)),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isSaving = ref.watch(outfitBuilderProvider.select((s) => s.isSaving));
              if (isSaving) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))),
                );
              }
              return TextButton(
                onPressed: () async {
                  final Uint8List? bytes = await _editorKey.currentState?.captureEditorImage();
                  
                  // Thêm kiểm tra `mounted` ngay sau await đầu tiên
                  if (bytes == null || !mounted) return;

                  final result = await showAnimatedDialog<Map<String, dynamic>>(
                    // ignore: use_build_context_synchronously
                    context,
                    barrierDismissible: false,
                    builder: (ctx) => _SaveOutfitDialog(),
                  );
                  
                  // Thêm kiểm tra `mounted` một lần nữa sau await thứ hai
                  if (result != null && mounted) {
                    ref.read(outfitBuilderProvider.notifier).saveOutfit(
                          name: result['name'] as String,
                          isFixed: result['isFixed'] as bool,
                          itemsOnCanvas: _itemsOnCanvas,
                          capturedImage: bytes,
                        );
                  }
                },
                child: Text(context.l10n.outfitsHub_save_button, style: Theme.of(context).appBarTheme.titleTextStyle),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 48), 
              Expanded(
                child: Container(
                  color: Colors.grey.shade200,
                  child: _imageData == null
                      ? const Center(child: CircularProgressIndicator())
                      : ProImageEditor.memory(
                          _imageData!,
                          key: _editorKey,
                          callbacks: ProImageEditorCallbacks(
                            mainEditorCallbacks: MainEditorCallbacks(
                              onRemoveLayer: (layer) {
                                if (_itemsOnCanvas.containsKey(layer.id)) { _itemsOnCanvas.remove(layer.id); }
                                _recalculateItemCounts();
                              },
                            ),
                            onImageEditingComplete: (_) async {},
                            onCloseEditor: (EditorMode mode) {
                              if (Navigator.of(context).canPop()) { Navigator.of(context).pop(false); }
                            },
                          ),
                          configs: ProImageEditorConfigs(   
                            i18n: getProImageEditorI18n(context.l10n),
                            layerInteraction: const LayerInteractionConfigs(
                                selectable: LayerInteractionSelectable.enabled,
                                initialSelected: false,
                                icons: LayerInteractionIcons(remove: Icons.clear, edit: Icons.edit_outlined, rotateScale: Icons.sync),
                              ),
                            mainEditor: MainEditorConfigs(
                              style: const MainEditorStyle(background: Colors.transparent),
                              widgets: MainEditorWidgets(appBar: (_, __) => null),
                            ),
                            textEditor: TextEditorConfigs(
                              showSelectFontStyleBottomBar: true,
                              customTextStyles: [ GoogleFonts.roboto(), GoogleFonts.beVietnamPro(), GoogleFonts.lora(), GoogleFonts.montserrat(), GoogleFonts.pacifico() ],
                            ),
                            stickerEditor: StickerEditorConfigs(
                              enabled: true,
                              builder: (setLayer, scrollController) => Center(child: Text(context.l10n.outfitBuilder_stickers_placeholder)),
                            ),
                            cropRotateEditor: const CropRotateEditorConfigs(enabled: false),
                            filterEditor: const FilterEditorConfigs(enabled: false),
                            blurEditor: const BlurEditorConfigs(enabled: false),
                            tuneEditor: const TuneEditorConfigs(enabled: false),
                          ),
                        ),
                ),
              ),
            ],
          ),
          _buildSecondaryToolbar(),
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

// Widget dialog không đổi
class _SaveOutfitDialog extends StatefulWidget {
  @override
  State<_SaveOutfitDialog> createState() => _SaveOutfitDialogState();
}

class _SaveOutfitDialogState extends State<_SaveOutfitDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFixed = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text(l10n.outfitBuilder_save_dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(hintText: l10n.outfitBuilder_save_nameHint),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.outfitBuilder_save_nameValidator;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.outfitBuilder_save_isFixedLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(l10n.outfitBuilder_save_isFixedSubtitle, style: const TextStyle(fontSize: 12)),
              value: _isFixed,
              onChanged: (newValue) => setState(() => _isFixed = newValue),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.outfitsHub_cancel_button)),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop({
                  'name': _nameController.text.trim(),
                  'isFixed': _isFixed,
                });
              }
            },
            child: Text(l10n.outfitsHub_save_button),
          ),
        ],
      ),
    );
  }
}