// lib/models/outfit_filter.dart
import 'package:equatable/equatable.dart';

class OutfitFilter extends Equatable {
  final String? closetId;
  final String? category; // Danh mục chính như "Áo (Tops)"
  final Set<String> colors;
  final Set<String> seasons;
  final Set<String> occasions;

  const OutfitFilter({
    this.closetId,
    this.category,
    this.colors = const {},
    this.seasons = const {},
    this.occasions = const {},
  });

  // Hàm kiểm tra xem có bộ lọc nào đang được áp dụng không
  bool get isApplied => closetId != null || category != null || colors.isNotEmpty || seasons.isNotEmpty || occasions.isNotEmpty;

  // Hàm copyWith để dễ dàng tạo đối tượng mới
  OutfitFilter copyWith({
    String? closetId,
    String? category,
    Set<String>? colors,
    Set<String>? seasons,
    Set<String>? occasions,
  }) {
    return OutfitFilter(
      closetId: closetId ?? this.closetId,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
    );
  }

  @override
  List<Object?> get props => [closetId, category, colors, seasons, occasions];
}