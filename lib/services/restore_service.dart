// lib/services/restore_service.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class RestoreService {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RestoreService(this._ref);

  /// Hàm chính để bắt đầu quá trình phục hồi.
  Future<void> performRestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in. Cannot perform restore.");
    }
    final userId = user.uid;
    logger.i("Bắt đầu phục hồi dữ liệu cho người dùng: $userId");

    // BƯỚC 12 (Phần 1): XÓA SẠCH DỮ LIỆU CỤC BỘ CŨ
    await _clearLocalData();
    
    // BƯỚC 10: TẢI DỮ LIỆU METADATA TỪ FIRESTORE
    final userDocRef = _firestore.collection('users').doc(userId);
    final itemsSnapshot = await userDocRef.collection('items').get();
    final itemsFromCloud = itemsSnapshot.docs.map((doc) => ClothingItem.fromMap(doc.data())).toList();
    final outfitsSnapshot = await userDocRef.collection('outfits').get();
    final outfitsFromCloud = outfitsSnapshot.docs.map((doc) => Outfit.fromMap(doc.data())).toList();
    logger.i("Đã tải về ${itemsFromCloud.length} vật phẩm và ${outfitsFromCloud.length} trang phục từ Firestore.");
    
    // BƯỚC 11: TẢI ẢNH TỪ CLOUD STORAGE VỀ MÁY
    final List<ClothingItem> itemsToSaveLocally = [];
    for (final item in itemsFromCloud) {
      final newLocalImagePath = await _downloadAndSaveImage(item.imagePath, item.id);
      final newLocalThumbnailPath = item.thumbnailPath != null
          ? await _downloadAndSaveImage(item.thumbnailPath!, 'thumb_${item.id}')
          : null;

      if (newLocalImagePath != null) {
        itemsToSaveLocally.add(item.copyWith(
          imagePath: newLocalImagePath,
          thumbnailPath: newLocalThumbnailPath,
        ));
      }
    }

    final List<Outfit> outfitsToSaveLocally = [];
    for (final outfit in outfitsFromCloud) {
      final newLocalImagePath = await _downloadAndSaveImage(outfit.imagePath, outfit.id);
      final newLocalThumbnailPath = outfit.thumbnailPath != null
          ? await _downloadAndSaveImage(outfit.thumbnailPath!, 'thumb_${outfit.id}')
          : null;
          
      if (newLocalImagePath != null) {
        outfitsToSaveLocally.add(outfit.copyWith(
          imagePath: newLocalImagePath,
          thumbnailPath: newLocalThumbnailPath,
        ));
      }
    }
    logger.i("Đã tải về và lưu lại cục bộ ${itemsToSaveLocally.length} ảnh vật phẩm và ${outfitsToSaveLocally.length} ảnh trang phục.");

    // BƯỚC 12 (Phần 2): GHI DỮ LIỆU MỚI ĐÃ XỬ LÝ VÀO SQLITE
    final itemRepo = _ref.read(clothingItemRepositoryProvider);
    final outfitRepo = _ref.read(outfitRepositoryProvider);

    if (itemsToSaveLocally.isNotEmpty) {
      await itemRepo.insertBatchItems(itemsToSaveLocally);
    }
    if (outfitsToSaveLocally.isNotEmpty) {
      for (final outfit in outfitsToSaveLocally) {
        // Outfit không có hàm batch insert nên chúng ta dùng vòng lặp
        await outfitRepo.insertOutfit(outfit);
      }
    }
    
    // TODO: Thêm logic phục hồi cho closets và wear_log nếu cần

    logger.i("Hoàn tất phục hồi! Đã ghi ${itemsToSaveLocally.length} vật phẩm và ${outfitsToSaveLocally.length} trang phục vào SQLite.");
  }

  /// Xóa tất cả dữ liệu trong các bảng SQLite và các file ảnh cũ.
  Future<void> _clearLocalData() async {
    try {
      logger.i("Bắt đầu xóa dữ liệu cục bộ cũ...");
      final dbHelper = _ref.read(dbHelperProvider);
      final db = await dbHelper.database;
      await db.delete('wear_log');
      await db.delete('outfits');
      await db.delete('clothing_items');
      await db.delete('closets');

      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
      logger.i("Đã xóa xong dữ liệu cục bộ cũ.");
    } catch (e, s) {
        logger.e("Lỗi khi xóa dữ liệu cục bộ.", error: e, stackTrace: s);
    }
  }

  /// Tải một ảnh từ URL và lưu vào bộ nhớ cục bộ.
  Future<String?> _downloadAndSaveImage(String url, String id) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final fileExtension = p.extension(url.split('?').first);
        final filePath = p.join(directory.path, '$id$fileExtension');
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e, s) {
      logger.e("Lỗi khi tải và lưu ảnh từ URL: $url", error: e, stackTrace: s);
    }
    return null;
  }
}

/// Provider để cung cấp một instance của RestoreService cho ứng dụng.
final restoreServiceProvider = Provider<RestoreService>((ref) {
  return RestoreService(ref);
});