// file: lib/screens/pages/outfit_builder_page.dart

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
  // Danh sách TẤT CẢ các món đồ trong tủ để hiển thị ở dưới
  List<ClothingItem> _allItemsInCloset = [];
  
  // Danh sách các món đồ đang được hiển thị trên canvas
  List<ClothingItem> _itemsOnCanvas = [];

  @override
  void initState() {
    super.initState();
    _loadAllClosetItems();
  }

  // Hàm tải tất cả các món đồ từ CSDL
  Future<void> _loadAllClosetItems() async {
    final dataList = await DatabaseHelper.instance.getAllItems();
    setState(() {
      _allItemsInCloset = dataList.map((item) => ClothingItem.fromMap(item)).toList();
    });
  }
  
  // Hàm thêm một món đồ từ bảng màu lên canvas
  void _addItemToCanvas(ClothingItem item) {
    setState(() {
      _itemsOnCanvas.add(item);
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
                children: _itemsOnCanvas.map((item) {
                  // Với mỗi món đồ trong danh sách, tạo một sticker
                  return ClothingSticker(item: item);
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