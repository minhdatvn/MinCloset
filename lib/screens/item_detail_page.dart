// file: lib/screens/item_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/widgets/detail_info_row.dart';

class ItemDetailPage extends StatelessWidget {
  final ClothingItem item;
  const ItemDetailPage({super.key, required this.item});

  // Hàm điều hướng sang trang Sửa
  void _navigateToEditItem(BuildContext context) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (ctx) => AddItemScreen(itemToEdit: item)),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  // Hàm hiển thị dialog và xử lý xóa
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
    // DefaultTabController vẫn bao bọc bên ngoài cùng
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết Món đồ'),
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
        // Cấu trúc body giờ là một Column
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PHẦN 1: HÌNH ẢNH
            Image.file(
              File(item.imagePath),
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // PHẦN 2: THANH TAB
            const TabBar(
              tabs: [
                Tab(text: 'Thông tin'),
                Tab(text: 'Phối đồ'),
              ],
            ),

            // PHẦN 3: NỘI DUNG TAB (dùng Expanded)
            Expanded(
              child: TabBarView(
                children: [
                  // Nội dung Tab 1: Thông tin
                  _buildInfoTab(context),
                  
                  // Nội dung Tab 2: Phối đồ (tạm thời)
                  const Center(child: Text('Các bộ đồ có sử dụng món đồ này sẽ hiện ở đây.')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget để xây dựng nội dung cho tab "Thông tin"
  Widget _buildInfoTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
          ),
          DetailInfoRow(label: 'Mùa', value: item.season ?? 'Chưa có'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          DetailInfoRow(label: 'Mục đích', value: item.occasion ?? 'Chưa có'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          DetailInfoRow(label: 'Loại', value: item.category),
          const Divider(height: 1, indent: 16, endIndent: 16),
          DetailInfoRow(label: 'Màu sắc', value: item.color),
          const Divider(height: 1, indent: 16, endIndent: 16),
          DetailInfoRow(label: 'Chất liệu', value: item.material ?? 'Chưa có'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          DetailInfoRow(label: 'Họa tiết', value: item.pattern ?? 'Chưa có'),
        ],
      ),
    );
  }
}