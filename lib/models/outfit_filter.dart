// lib/models/outfit_filter.dart
import 'package:equatable/equatable.dart';

class OutfitFilter extends Equatable {
  final String? closetId;
  final String? category; // Danh mục chính như "Áo (Tops)"
  final Set<String> colors;
  final Set<String> seasons;
  final Set<String> occasions;
  final Set<String> materials; // <<< THÊM MỚI
  final Set<String> patterns;  // <<< THÊM MỚI

  const OutfitFilter({
    this.closetId,
    this.category,
    this.colors = const {},
    this.seasons = const {},
    this.occasions = const {},
    this.materials = const {}, // <<< THÊM MỚI
    this.patterns = const {},  // <<< THÊM MỚI
  });

  // Hàm kiểm tra xem có bộ lọc nào đang được áp dụng không
  bool get isApplied =>
      closetId != null ||
      category != null ||
      colors.isNotEmpty ||
      seasons.isNotEmpty ||
      occasions.isNotEmpty ||
      materials.isNotEmpty || // <<< THÊM MỚI
      patterns.isNotEmpty;   // <<< THÊM MỚI

  // Hàm copyWith để dễ dàng tạo đối tượng mới
  OutfitFilter copyWith({
    String? closetId,
    String? category,
    Set<String>? colors,
    Set<String>? seasons,
    Set<String>? occasions,
    Set<String>? materials, // <<< THÊM MỚI
    Set<String>? patterns,  // <<< THÊM MỚI
  }) {
    return OutfitFilter(
      closetId: closetId ?? this.closetId,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      materials: materials ?? this.materials, // <<< THÊM MỚI
      patterns: patterns ?? this.patterns,   // <<< THÊM MỚI
    );
  }

  @override
  List<Object?> get props =>
      [closetId, category, colors, seasons, occasions, materials, patterns];
}