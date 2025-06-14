import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/screens/pages/closet_detail_page.dart';
import 'package:uuid/uuid.dart';

class ClosetsPage extends StatefulWidget {
  const ClosetsPage({super.key});

  @override
  State<ClosetsPage> createState() => _ClosetsPageState();
}

class _ClosetsPageState extends State<ClosetsPage> {
  void _showAddClosetDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo tủ đồ mới'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên tủ đồ'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final navigator = Navigator.of(ctx);
              final newCloset = Closet(id: const Uuid().v4(), name: nameController.text.trim());
              await DatabaseHelper.instance.insertCloset(newCloset.toMap());
              if (mounted) {
                navigator.pop();
                setState(() {});
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditClosetDialog(Closet closet) {
    final nameController = TextEditingController(text: closet.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa tên tủ đồ'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên mới'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final navigator = Navigator.of(ctx);
              final updatedCloset = Closet(id: closet.id, name: nameController.text.trim());
              await DatabaseHelper.instance.updateCloset(updatedCloset);
              if (mounted) {
                navigator.pop();
                setState(() {});
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Closet closet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa tủ đồ "${closet.name}"? Mọi món đồ bên trong cũng sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              await DatabaseHelper.instance.deleteCloset(closet.id);
              if (mounted) {
                navigator.pop();
                setState(() {});
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
        title: const Text('Quản lý Tủ đồ'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getClosets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Bạn chưa có tủ đồ nào.\nHãy nhấn nút + để tạo tủ đồ đầu tiên!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)));
          
          final closets = snapshot.data!.map((map) => Closet.fromMap(map)).toList();
          return ListView.builder(
            itemCount: closets.length,
            itemBuilder: (ctx, index) {
              final closet = closets[index];
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(closet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showEditClosetDialog(closet), tooltip: 'Sửa tên'),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteConfirmDialog(closet), tooltip: 'Xóa tủ đồ'),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ClosetDetailPage(closet: closet)),
                  ).then((_) => setState(() {}));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'closets_page_fab',
        onPressed: _showAddClosetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}