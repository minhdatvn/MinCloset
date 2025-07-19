// lib/services/backup_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/utils/logger.dart';


/// Lớp này chứa toàn bộ logic để sao lưu dữ liệu của người dùng
/// từ SQLite cục bộ lên Firebase (Firestore và Storage).
class BackupService {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  BackupService(this._ref);

  /// Hàm chính để bắt đầu quá trình sao lưu.
  Future<void> performBackup() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in. Cannot perform backup.");
    }

    final userId = user.uid;
    logger.i("Bắt đầu sao lưu cho người dùng: $userId");

    // 1. XÓA SẠCH DỮ LIỆU CŨ TRÊN CLOUD
    await _deleteAllUserData(userId);

    // 2. Lấy tất cả dữ liệu từ các repository cục bộ
    final closetRepo = _ref.read(closetRepositoryProvider); // <<< THÊM MỚI
    final itemRepo = _ref.read(clothingItemRepositoryProvider);
    final outfitRepo = _ref.read(outfitRepositoryProvider);

    final allClosetsEither = await closetRepo.getClosets(); // <<< THÊM MỚI
    final allItemsEither = await itemRepo.getAllItems();
    final allOutfitsEither = await outfitRepo.getOutfits();

    final allClosets = allClosetsEither.getOrElse((_) => []); // <<< THÊM MỚI
    final allItems = allItemsEither.getOrElse((_) => []);
    final allOutfits = allOutfitsEither.getOrElse((_) => []);
    logger.i("Đã đọc được ${allClosets.length} tủ đồ, ${allItems.length} vật phẩm và ${allOutfits.length} trang phục từ CSDL cục bộ.");

    // 3. Tải tất cả ảnh lên Cloud Storage và lấy URL mới
    final Map<String, ClothingItem> updatedItems = {};
    for (final item in allItems) {
      final newImageUrl = await _uploadImage(userId, 'items', item.id, item.imagePath);
      final newThumbnailUrl = item.thumbnailPath != null
          ? await _uploadImage(userId, 'thumbnails', item.id, item.thumbnailPath!)
          : null;

      if (newImageUrl != null) {
        updatedItems[item.id] = item.copyWith(
          imagePath: newImageUrl,
          thumbnailPath: newThumbnailUrl ?? newImageUrl,
        );
      }
    }

    final Map<String, Outfit> updatedOutfits = {};
    for (final outfit in allOutfits) {
      final newImageUrl = await _uploadImage(userId, 'outfits', outfit.id, outfit.imagePath);
      final newThumbnailUrl = outfit.thumbnailPath != null
          ? await _uploadImage(userId, 'outfits_thumbnails', outfit.id, outfit.thumbnailPath!)
          : null;

      if (newImageUrl != null) {
        updatedOutfits[outfit.id] = outfit.copyWith(
          imagePath: newImageUrl,
          thumbnailPath: newThumbnailUrl,
        );
      }
    }
    logger.i("Đã tải lên thành công ảnh cho ${updatedItems.length} vật phẩm và ${updatedOutfits.length} trang phục.");

    // 4. GHI DỮ LIỆU METADATA MỚI LÊN FIRESTORE
    final userDocRef = _firestore.collection('users').doc(userId);
    final batch = _firestore.batch();

    // <<< THÊM MỚI: Ghi các tủ đồ vào sub-collection 'closets' >>>
    for (final closet in allClosets) {
      final closetDoc = userDocRef.collection('closets').doc(closet.id);
      batch.set(closetDoc, closet.toMap());
    }

    // Ghi các vật phẩm vào sub-collection 'items'
    for (final item in updatedItems.values) {
      final itemDoc = userDocRef.collection('items').doc(item.id);
      batch.set(itemDoc, item.toMap());
    }

    // Ghi các trang phục vào sub-collection 'outfits'
    for (final outfit in updatedOutfits.values) {
      final outfitDoc = userDocRef.collection('outfits').doc(outfit.id);
      batch.set(outfitDoc, outfit.toMap());
    }

    // Ghi lại dấu thời gian của lần sao lưu cuối cùng
    batch.set(userDocRef, {'lastBackup': Timestamp.now()}, SetOptions(merge: true));

    // Thực thi tất cả các lệnh ghi cùng một lúc
    await batch.commit();

    logger.i("Hoàn tất việc ghi ${allClosets.length} tủ đồ, ${updatedItems.length} vật phẩm và ${updatedOutfits.length} trang phục lên Firestore.");
  }

  /// Hàm helper để xóa toàn bộ dữ liệu cũ của người dùng trên cloud.
  Future<void> _deleteAllUserData(String userId) async {
    try {
      logger.i("Bắt đầu xóa dữ liệu sao lưu cũ cho người dùng: $userId");

      // Xóa tất cả file trong Cloud Storage
      final userFolderRef = _storage.ref(userId);
      try {
        final ListResult result = await userFolderRef.listAll();
        for (final Reference folder in result.prefixes) {
          final ListResult items = await folder.listAll();
          for (final Reference item in items.items) {
            await item.delete();
          }
        }
        logger.i("Đã xóa xong các file cũ trên Cloud Storage.");
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          // Đây là trường hợp bình thường trong lần backup đầu tiên.
          // Bỏ qua lỗi và tiếp tục.
          logger.i("Không tìm thấy dữ liệu cũ trên Cloud Storage để xóa (lần đầu sao lưu).");
        } else {
          // Ném ra các lỗi khác không mong muốn (ví dụ: permission denied)
          rethrow;
        }
      }

      // Xóa tất cả document trong Firestore (logic không đổi)
      final userDocRef = _firestore.collection('users').doc(userId);
      final collections = ['items', 'outfits']; // Thêm các collection khác vào đây nếu có
      for (final collection in collections) {
          final snapshot = await userDocRef.collection(collection).get();
          if (snapshot.docs.isNotEmpty) {
              final batch = _firestore.batch();
              for (final doc in snapshot.docs) {
                  batch.delete(doc.reference);
              }
              await batch.commit();
          }
      }
      logger.i("Đã xóa xong các document cũ trên Firestore.");

    } catch (e, s) {
      logger.e("Lỗi nghiêm trọng khi xóa dữ liệu cũ.", error: e, stackTrace: s);
      throw Exception("Failed to clear old backup data. Please try again.");
    }
  }

  /// Hàm helper để tải một file ảnh lên Cloud Storage.
  Future<String?> _uploadImage(String userId, String folder, String fileId, String localPath) async {
    // ... (Hàm này không thay đổi)
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        logger.w("File không tồn tại tại đường dẫn cục bộ: $localPath");
        return null;
      }
      
      final ref = _storage.ref('$userId/$folder/$fileId.jpg');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e, s) {
      logger.e("Lỗi khi tải ảnh '$localPath' lên Cloud Storage", error: e, stackTrace: s);
      return null;
    }
  }
}

/// Provider để cung cấp một instance của BackupService cho ứng dụng.
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref);
});