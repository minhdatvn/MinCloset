// lib/notifiers/outfit_builder_notifier.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final DatabaseHelper _dbHelper;
  int _stickerCounter = 0;

  OutfitBuilderNotifier(this._dbHelper) : super(const OutfitBuilderState()) {
    loadAvailableItems();
  }

  Future<void> loadAvailableItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final itemsData = await _dbHelper.getAllItems();
      final items = itemsData.map((map) => ClothingItem.fromMap(map)).toList();
      state = state.copyWith(availableItems: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: "Không thể tải danh sách đồ", isLoading: false);
    }
  }

  void addItemToCanvas(ClothingItem item) {
    final newStickerId = 'sticker_${_stickerCounter++}';
    final newCanvasItems = Map<String, ClothingItem>.from(state.itemsOnCanvas);
    newCanvasItems[newStickerId] = item;
    state = state.copyWith(itemsOnCanvas: newCanvasItems, selectedStickerId: newStickerId);
  }

  void selectSticker(String stickerId) {
    final itemToBringForward = state.itemsOnCanvas[stickerId];
    if (itemToBringForward == null) return;

    final newCanvasItems = Map<String, ClothingItem>.from(state.itemsOnCanvas);
    newCanvasItems.remove(stickerId);
    newCanvasItems[stickerId] = itemToBringForward;

    state = state.copyWith(itemsOnCanvas: newCanvasItems, selectedStickerId: stickerId);
  }

  void deselectAllStickers() {
    state = state.copyWith(clearSelectedSticker: true);
  }

  void deleteSticker(String stickerId) {
    final newCanvasItems = Map<String, ClothingItem>.from(state.itemsOnCanvas);
    newCanvasItems.remove(stickerId);
    state = state.copyWith(itemsOnCanvas: newCanvasItems, clearSelectedSticker: true);
  }

  Future<void> saveOutfit(String name, Uint8List capturedImage) async {
    if (state.itemsOnCanvas.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng thêm ít nhất một món đồ để lưu!');
      return;
    }
    state = state.copyWith(isSaving: true, saveSuccess: false, errorMessage: null);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = p.join(directory.path, '${const Uuid().v4()}.png');
      await File(imagePath).writeAsBytes(capturedImage);

      final itemIds = state.itemsOnCanvas.values.map((item) => item.id).join(',');

      final newOutfit = Outfit(
        id: const Uuid().v4(),
        name: name,
        imagePath: imagePath,
        itemIds: itemIds,
      );

      await _dbHelper.insertOutfit(newOutfit);
      state = state.copyWith(isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: "Lỗi khi lưu bộ đồ: $e");
    }
  }
}

final outfitBuilderProvider = StateNotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  return OutfitBuilderNotifier(ref.watch(dbHelperProvider));
});