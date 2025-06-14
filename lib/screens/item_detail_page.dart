// file: lib/screens/item_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/screens/add_item_screen.dart';

class ItemDetailPage extends StatelessWidget { // Chuyển về StatelessWidget là đủ
  final ClothingItem item;
  const ItemDetailPage({super.key, required this.item});

  void _navigateToEditItem(BuildContext context) {
    // Khi đi đến trang sửa, ta mong muốn trang danh sách sẽ được refresh khi quay về
    // nên ta sẽ pop trang chi tiết này sau khi sửa xong.
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (ctx) => AddItemScreen(itemToEdit: item)),
    ).then((result) {
      // Nếu trang sửa trả về true (đã cập nhật), ta đóng luôn trang chi tiết
      // để màn hình danh sách phía sau tự refresh
      if (result == true && context.mounted) {
        Navigator.of(context).pop(true); // Trả về true cho trang danh sách
      }
    });
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await DBHelper.deleteItem(item.id);
              if (context.mounted) {
                navigator.pop(); // Đóng dialog
                navigator.pop(true); // Đóng trang chi tiết và báo hiệu đã xóa
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEditItem(context),
            tooltip: 'Sửa món đồ',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteItem(context),
            tooltip: 'Xóa món đồ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(item.imagePath),
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Chip(label: Text('Danh mục: ${item.category}')),
                  const SizedBox(height: 8),
                  Chip(label: Text('Màu sắc: ${item.color}')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}