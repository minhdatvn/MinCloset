// lib/services/web_cache_service.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/utils/logger.dart';

/// Quản lý việc tải và lưu cache cho các file web (HTML).
class WebCacheService {
  final CacheManager _cacheManager;

  WebCacheService(this._cacheManager);

  /// Lấy về đường dẫn file đã được cache.
  ///
  /// Hàm này sẽ cố gắng tải phiên bản mới nhất nếu file đã cũ (hơn 24 giờ)
  /// và có kết nối mạng. Nếu không, nó sẽ trả về phiên bản cũ trong cache.
  Future<String?> getCachedFilePath(String url) async {
    try {
      // Cố gắng tải file từ cache hoặc từ mạng nếu cần.
      // stalePeriod: Thời gian tối đa giữ lại file cũ trước khi cố gắng tải lại.
      final file = await _cacheManager.getSingleFile(url);
      return file.path;
    } catch (e, s) {
      logger.e("Lỗi khi lấy file từ cache cho URL: $url", error: e, stackTrace: s);
      // Nếu có lỗi (ví dụ: không có mạng và file cũng không có trong cache),
      // thử lấy file cũ nhất trong cache (nếu có).
      final fileInfo = await _cacheManager.getFileFromCache(url);
      return fileInfo?.file.path;
    }
  }
}

/// Provider để cung cấp một instance của WebCacheService.
final webCacheServiceProvider = Provider<WebCacheService>((ref) {
  // Cấu hình CacheManager với một key duy nhất cho các trang web tĩnh.
  // stalePeriod: Thời gian tối đa mà một file được coi là "tươi" trước khi
  // CacheManager cố gắng tải lại nó trong lần truy cập tiếp theo.
  final customCacheManager = CacheManager(
    Config(
      'static_web_pages_cache',
      stalePeriod: const Duration(days: 1), // File sẽ được làm mới sau 1 ngày
      maxNrOfCacheObjects: 20, // Lưu tối đa 20 trang web
    ),
  );
  return WebCacheService(customCacheManager);
});