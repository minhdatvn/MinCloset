// lib/models/wear_log.dart
import 'package:mincloset/models/clothing_item.dart';

class WearLog {
  final int id;
  final String itemId;
  final String? outfitId;
  final DateTime wearDate;

  // Trường này sẽ được thêm vào sau khi truy vấn
  final ClothingItem? item;

  const WearLog({
    required this.id,
    required this.itemId,
    this.outfitId,
    required this.wearDate,
    this.item,
  });

  WearLog copyWith({ClothingItem? item}) {
    return WearLog(
      id: id,
      itemId: itemId,
      outfitId: outfitId,
      wearDate: wearDate,
      item: item ?? this.item,
    );
  }

  factory WearLog.fromMap(Map<String, dynamic> map) {
    return WearLog(
      id: map['id'] as int,
      itemId: map['item_id'] as String,
      outfitId: map['outfit_id'] as String?,
      wearDate: DateTime.parse(map['wear_date'] as String),
    );
  }
}