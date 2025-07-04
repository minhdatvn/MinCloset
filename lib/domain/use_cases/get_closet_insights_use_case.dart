// lib/domain/use_cases/get_closet_insights_use_case.dart
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/models/item_insight.dart';
import 'package:mincloset/domain/models/closet_insights.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/wear_log_repository.dart';

class GetClosetInsightsUseCase {
  final ClothingItemRepository _itemRepo;
  final WearLogRepository _wearLogRepo;

  GetClosetInsightsUseCase(this._itemRepo, this._wearLogRepo);

  FutureEither<ClosetInsights> execute() async {
    try {
      // 1. Lấy tất cả dữ liệu cần thiết từ repositories
      final itemsEither = await _itemRepo.getAllItems();
      final logsEither = await _wearLogRepo.getLogsForDateRange(
        DateTime(2000), // Lấy từ thời gian rất xa trong quá khứ
        DateTime.now().add(const Duration(days: 1)), // Đến ngày mai để bao gồm cả hôm nay
      );

      // Xử lý nếu có lỗi khi lấy dữ liệu
      if (itemsEither.isLeft()) {
        return Left(itemsEither.getLeft().getOrElse(() => const GenericFailure('Failed to get items')));
      }
      if (logsEither.isLeft()) {
        return Left(logsEither.getLeft().getOrElse(() => const GenericFailure('Failed to get wear logs')));
      }

      final allItems = itemsEither.getRight().getOrElse(() => []);
      final allLogs = logsEither.getRight().getOrElse(() => []);
      
      if (allItems.isEmpty) {
        return const Left(GenericFailure('Add items with prices to see insights.'));
      }

      // 2. Tính toán số lần mặc cho mỗi vật phẩm
      final wearCounts = allLogs.groupListsBy((log) => log.itemId)
                                 .map((key, value) => MapEntry(key, value.length));

      // 3. Tạo danh sách các ItemInsight với đầy đủ thông tin
      final List<ItemInsight> allItemInsights = [];
      for (final item in allItems) {
        final wearCount = wearCounts[item.id] ?? 0;
        final price = item.price ?? 0.0;
        double costPerWear = double.infinity;
        if (wearCount > 0 && price > 0) {
          costPerWear = price / wearCount;
        } else if (price > 0 && wearCount == 0) {
          costPerWear = price; // Coi như CPW bằng giá gốc nếu chưa mặc
        }

        allItemInsights.add(ItemInsight(
          item: item,
          wearCount: wearCount,
          costPerWear: costPerWear,
        ));
      }

      // 4. Phân loại và sắp xếp dữ liệu
      final itemsWithPrice = allItemInsights.where((insight) => (insight.item.price ?? 0) > 0).toList();
      
      itemsWithPrice.sort((a, b) => a.costPerWear.compareTo(b.costPerWear));
      final bestValueItems = itemsWithPrice.take(5).toList();

      final forgottenItems = allItemInsights.where((insight) => insight.wearCount <= 1 && (insight.item.price ?? 0) > 0).toList();
      forgottenItems.sort((a, b) => (b.item.price ?? 0).compareTo(a.item.price ?? 0));

      allItemInsights.sort((a, b) => b.wearCount.compareTo(a.wearCount));
      final mostWornItems = allItemInsights.take(5).toList();

      // 5. Tính toán các chỉ số tổng quan
      final totalValue = allItems.fold<double>(0.0, (sum, item) => sum + (item.price ?? 0));
      final Map<String, double> valueByCategory = {};
      for (var item in allItems) {
          if (item.price != null && item.price! > 0) {
              final mainCategory = item.category.split(' > ').first.trim();
              valueByCategory[mainCategory] = (valueByCategory[mainCategory] ?? 0) + item.price!;
          }
      }

      // 6. Tạo và trả về đối tượng kết quả cuối cùng
      final insights = ClosetInsights(
        totalValue: totalValue,
        valueByCategory: valueByCategory,
        mostWornItems: mostWornItems,
        bestValueItems: bestValueItems,
        forgottenItems: forgottenItems.take(5).toList(),
      );

      return Right(insights);

    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}