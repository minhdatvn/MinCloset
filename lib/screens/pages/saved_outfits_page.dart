// file: lib/screens/pages/saved_outfits_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:share_plus/share_plus.dart';


class SavedOutfitsPage extends StatefulWidget {
  const SavedOutfitsPage({super.key});

  @override
  State<SavedOutfitsPage> createState() => _SavedOutfitsPageState();
}

class _SavedOutfitsPageState extends State<SavedOutfitsPage> {
  late Future<List<Outfit>> _outfitsFuture;

  @override
  void initState() {
    super.initState();
    _outfitsFuture = _loadOutfits();
  }

  Future<List<Outfit>> _loadOutfits() {
    return DatabaseHelper.instance.getOutfits();
  }

  void _refreshOutfits() {
    setState(() {
      _outfitsFuture = _loadOutfits();
    });
  }

  // === HÀM CHIA SẺ ĐÃ ĐƯỢC SỬA ĐÚNG 100% ===
  Future<void> _shareOutfit(Outfit outfit) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // Sử dụng cách viết mới và chính xác
      await SharePlus.instance.share(
        ShareParams(
          text: 'Cùng xem bộ đồ "${outfit.name}" của tôi trên MinCloset nhé!',
          files: [XFile(outfit.imagePath)],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Lỗi khi chia sẻ: $e')));
    }
  }

  Future<void> _deleteOutfit(BuildContext context, Outfit outfit) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn bộ đồ "${outfit.name}" không?'),
        actions: [
          TextButton(onPressed: () => navigator.pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => navigator.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteOutfit(outfit.id);
      try {
        final imageFile = File(outfit.imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (e) {
        debugPrint("Lỗi khi xóa file ảnh: $e");
      }
      
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Đã xóa bộ đồ "${outfit.name}".')),
      );
      _refreshOutfits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ đồ đã lưu'),
      ),
      body: FutureBuilder<List<Outfit>>(
        future: _outfitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa lưu bộ đồ nào cả.\nHãy vào "Xưởng Phối đồ" để sáng tạo nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final outfits = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: outfits.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (ctx, index) {
              final outfit = outfits[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.file(
                        File(outfit.imagePath),
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blue),
                            onPressed: () => _shareOutfit(outfit),
                            tooltip: 'Chia sẻ',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteOutfit(context, outfit),
                            tooltip: 'Xóa',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}