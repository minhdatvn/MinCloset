// lib/domain/models/suggestion_result.dart

import 'package:mincloset/models/clothing_item.dart';

class SuggestionResult {
  final String outfitName;
  final String reason;
  // Map từ "slot" (vd: 'topwear') đến đối tượng ClothingItem tương ứng
  final Map<String, ClothingItem?> composition;

  SuggestionResult({
    required this.outfitName,
    required this.reason,
    required this.composition,
  });
}