// file: lib/screens/pages/closet_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/screens/item_detail_page.dart'; // <-- THÊM IMPORT MỚI
import 'package:mincloset/widgets/recent_item_card.dart';

class ClosetDetailPage extends StatefulWidget {
  final Closet closet;
  const ClosetDetailPage({super.key, required this.closet});

  @override
  State<ClosetDetailPage> createState() => _ClosetDetailPageState();
}

class _ClosetDetailPageState extends State<ClosetDetailPage> {
  late Future<List<ClothingItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }
  
  // Chuyển logic load thành một thuộc tính Future
  Future<List<ClothingItem>> _loadItems() {
    return DBHelper.getItemsInCloset(widget.closet.id)
        .then((dataList) => dataList.map((item) => ClothingItem.fromMap(item)).toList());
  }

  void _refreshItems() {
    setState(() {
      _itemsFuture = _loadItems();
    });
  }

  void _navigateToAddItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddItemScreen(preselectedClosetId: widget.closet.id),
      ),
    ).then((_) => _refreshItems()); // Refresh lại khi quay về
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.closet.name),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm đồ vào tủ này',
            onPressed: _navigateToAddItem,
          ),
        ],
      ),
      body: FutureBuilder<List<ClothingItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tủ đồ này chưa có gì cả.\nHãy nhấn nút + ở trên để thêm nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final items = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 3/4, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemBuilder: (ctx, index) {
              final item = items[index];
              return GestureDetector( // <-- BỌC TRONG GESTUREDETECTOR
                onTap: () {
                  Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(item: item),
                    ),
                  ).then((result) {
                    // Nếu kết quả trả về là true (đã xóa), thì refresh lại danh sách
                    if (result == true) {
                      _refreshItems();
                    }
                  });
                },
                child: RecentItemCard(item: item),
              );
            },
          );
        },
      ),
    );
  }
}