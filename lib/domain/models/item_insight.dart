// lib/domain/models/item_insight.dart
import 'package:mincloset/models/clothing_item.dart';

class ItemInsight {
  final ClothingItem item;
  final int wearCount;
  final double costPerWear;

  const ItemInsight({
    required this.item,
    required this.wearCount,
    required this.costPerWear,
  });
}