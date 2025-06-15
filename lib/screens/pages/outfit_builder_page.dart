// lib/screens/pages/outfit_builder_page.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:mincloset/widgets/clothing_sticker.dart';

class OutfitBuilderPage extends StatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  State<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends State<OutfitBuilderPage> {
  // --- Các biến trạng thái ---
  List<ClothingItem> _allItemsInCloset = [];
  final Map<String, ClothingItem> _itemsOnCanvas = {};
  int _stickerCounter = 0;
  final _screenshotController = ScreenshotController();
  bool _isSaving = false;
  String? _selectedStickerId;

  @override
  void initState() {
    super.initState();
    _loadAllClosetItems();
  }

  Future<void> _loadAllClosetItems() async {
    final dataList = await DatabaseHelper.instance.getAllItems();
    setState(() {
      _allItemsInCloset = dataList.map((item) => ClothingItem.fromMap(item)).toList();
    });
  }

  void _addItemToCanvas(ClothingItem item) {
    setState(() {
      final newStickerId = 'sticker_${_stickerCounter++}';
      _itemsOnCanvas[newStickerId] = item;
      _selectedStickerId = newStickerId;
    });
  }

  void _onStickerDelete(String stickerId) {
    setState(() {
      _itemsOnCanvas.remove(stickerId);
      _selectedStickerId = null;
    });
  }

  void _onStickerSelect(String stickerId) {
    final selectedItem = _itemsOnCanvas[stickerId];
    if (selectedItem == null) return;
    setState(() {
      _itemsOnCanvas.remove(stickerId);
      _itemsOnCanvas[stickerId] = selectedItem;
      _selectedStickerId = stickerId;
    });
  }
  
  void _deselectAllStickers() {
    setState(() {
      _selectedStickerId = null;
    });
  }
  
  Future<void> _saveOutfit() async {
    if (_itemsOnCanvas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một món đồ để lưu!')),
      );
      return;
    }
    final outfitName = await _showNameOutfitDialog();
    if (outfitName == null || outfitName.trim().isEmpty) return;

    setState(() {
      _isSaving = true;
      _selectedStickerId = null;
    });

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final Uint8List? capturedImage = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );
      if (capturedImage == null) throw Exception('Không thể chụp ảnh màn hình.');

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = p.join(directory.path, '${const Uuid().v4()}.png');
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(capturedImage);
      final itemIds = _itemsOnCanvas.values.map((item) => item.id).join(',');

      final newOutfit = Outfit(
        id: const Uuid().v4(),
        name: outfitName,
        imagePath: imagePath,
        itemIds: itemIds,
      );
      await DatabaseHelper.instance.insertOutfit(newOutfit);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu bộ đồ "$outfitName" thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu bộ đồ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  
  Future<String?> _showNameOutfitDialog() {
    final nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt tên cho bộ đồ'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Ví dụ: Dạo phố cuối tuần'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(nameController.text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xưởng Phối đồ'),
        actions: [
          // Đoạn code này sử dụng _isSaving và gọi _saveOutfit
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveOutfit, // Gọi hàm lưu
              tooltip: 'Lưu bộ đồ',
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: GestureDetector(
                onTap: _deselectAllStickers,
                child: Container(
                  color: Colors.grey.shade200,
                  child: Stack(
                    children: _itemsOnCanvas.entries.map((entry) {
                      final stickerId = entry.key;
                      final item = entry.value;
                      return ClothingSticker(
                        key: ValueKey(stickerId),
                        item: item,
                        isSelected: stickerId == _selectedStickerId,
                        onSelect: () => _onStickerSelect(stickerId),
                        onDelete: () => _onStickerDelete(stickerId),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          // Phần thanh chọn đồ ở dưới
          Container(
            height: 120,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _allItemsInCloset.length,
              itemBuilder: (ctx, index) {
                final item = _allItemsInCloset[index];
                return GestureDetector(
                  onTap: () => _addItemToCanvas(item),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Image.file(File(item.imagePath), fit: BoxFit.contain),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}