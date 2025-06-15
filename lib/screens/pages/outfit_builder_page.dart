import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/widgets/clothing_sticker.dart';

class OutfitBuilderPage extends StatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  State<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends State<OutfitBuilderPage> {
  List<ClothingItem> _allItemsInCloset = [];
  // Thay đổi: mỗi sticker giờ là một đối tượng duy nhất, ta dùng Map
  // để lưu trữ chúng với một key duy nhất, giúp việc xóa dễ dàng hơn.
  final Map<String, ClothingItem> _itemsOnCanvas = {};
  int _stickerCounter = 0; // Để tạo key duy nhất

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
      // Mỗi khi thêm, tạo một key duy nhất cho sticker mới
      final newStickerId = 'sticker_${_stickerCounter++}';
      _itemsOnCanvas[newStickerId] = item;
    });
  }

  // === HÀM MỚI ĐỂ XÓA STICKER ===
  void _onStickerDelete(String stickerId) {
    setState(() {
      _itemsOnCanvas.remove(stickerId);
    });
  }

  // === HÀM MỚI ĐỂ ĐƯA LÊN TRÊN CÙNG ===
  void _onStickerSelect(String stickerId) {
    // Lấy ra món đồ được chọn
    final selectedItem = _itemsOnCanvas[stickerId];
    if (selectedItem == null) return;
    
    setState(() {
      // Xóa nó khỏi vị trí hiện tại và thêm lại vào cuối Map
      // Map trong Dart 3+ giữ nguyên thứ tự chèn, nên phần tử cuối sẽ được vẽ trên cùng
      _itemsOnCanvas.remove(stickerId);
      _itemsOnCanvas[stickerId] = selectedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xưởng Phối đồ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Logic lưu bộ đồ sẽ ở đây
            },
            tooltip: 'Lưu bộ đồ',
          )
        ],
      ),
      body: Column(
        children: [
          // === KHUNG CANVAS ===
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              // Stack cho phép các sticker xếp chồng lên nhau
              child: Stack(
                // Lấy ra các giá trị của Map để build UI
                children: _itemsOnCanvas.entries.map((entry) {
                  final stickerId = entry.key;
                  final item = entry.value;
                  return ClothingSticker(
                    key: ValueKey(stickerId), // Key giúp Flutter nhận diện widget
                    item: item,
                    // Truyền các hàm xử lý xuống cho sticker
                    onSelect: () => _onStickerSelect(stickerId),
                    onDelete: () => _onStickerDelete(stickerId),
                  );
                }).toList(),
              ),
            ),
          ),

          // === BẢNG MÀU QUẦN ÁO ===
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