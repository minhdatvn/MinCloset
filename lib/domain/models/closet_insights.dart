// lib/domain/models/closet_insights.dart
import 'package:mincloset/domain/models/item_insight.dart';

class ClosetInsights {
  final double totalValue;
  final Map<String, double> valueByCategory;
  final List<ItemInsight> mostWornItems;
  final List<ItemInsight> bestValueItems;
  final List<ItemInsight> forgottenItems;

  const ClosetInsights({
    required this.totalValue,
    required this.valueByCategory,
    required this.mostWornItems,
    required this.bestValueItems,
    required this.forgottenItems,
  });
}