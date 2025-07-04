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
      final lastWornDates = <String, DateTime>{};

      // Vì logs đã được sắp xếp giảm dần theo ngày, log đầu tiên của mỗi item
      // chính là lần mặc cuối cùng.
      final groupedLogs = allLogs.groupListsBy((log) => log.itemId);
      groupedLogs.forEach((itemId, logs) {
        wearCounts[itemId] = logs.length;
        if (logs.isNotEmpty) {
          lastWornDates[itemId] = logs.first.wearDate;
        }
      });

      // 3. Tạo danh sách các ItemInsight với đầy đủ thông tin
      final List<ItemInsight> allItemInsights = [];
      for (final item in allItems) {
        final wearCount = wearCounts[item.id] ?? 0;
        final price = item.price ?? 0.0;
        double costPerWear = double.infinity;

        if (wearCount > 0 && price > 0) {
          costPerWear = price / wearCount;
        }

        allItemInsights.add(ItemInsight(
          item: item,
          wearCount: wearCount,
          costPerWear: costPerWear,
          lastWornDate: lastWornDates[item.id], // Thêm ngày mặc cuối cùng
        ));
      }

      // 4. Phân loại và sắp xếp dữ liệu
      // Smartest Investments: có giá, đã mặc > 0 lần
      final bestValueItems = allItemInsights
          .where((i) => i.wearCount > 0 && (i.item.price ?? 0) > 0)
          .sorted((a, b) => a.costPerWear.compareTo(b.costPerWear))
          .take(5)
          .toList();

      // Forgotten Items: Theo đúng định nghĩa của bạn
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final forgottenItems = allItemInsights.where((insight) {
        // Điều kiện 1: Chưa mặc lần nào
        if (insight.wearCount == 0) return true;
        // Điều kiện 2: Đã mặc, nhưng lần cuối là hơn 3 tháng trước
        if (insight.lastWornDate != null && insight.lastWornDate!.isBefore(threeMonthsAgo)) {
          return true;
        }
        return false;
      }).toList();

      // Most Worn Items (giữ nguyên logic)
      final mostWornItems = allItemInsights
          .where((i) => i.wearCount > 0)
          .sorted((a, b) => b.wearCount.compareTo(a.wearCount))
          .take(5)
          .toList();

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