// lib/models/clothing_item.dart
import 'package:equatable/equatable.dart';

class ClothingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final String? thumbnailPath;
  final String closetId;
  final String? season;
  final String? occasion;
  final String? material;
  final String? pattern;
  final bool isFavorite; // <<< THÊM DÒNG NÀY

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    this.thumbnailPath,
    required this.closetId,
    this.season,
    this.occasion,
    this.material,
    this.pattern,
    this.isFavorite = false, // <<< THÊM GIÁ TRỊ MẶC ĐỊNH
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    String? imagePath,
    String? thumbnailPath,
    String? closetId,
    String? season,
    String? occasion,
    String? material,
    String? pattern,
    bool? isFavorite, // <<< THÊM DÒNG NÀY
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      closetId: closetId ?? this.closetId,
      season: season ?? this.season,
      occasion: occasion ?? this.occasion,
      material: material ?? this.material,
      pattern: pattern ?? this.pattern,
      isFavorite: isFavorite ?? this.isFavorite, // <<< THÊM DÒNG NÀY
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'closetId': closetId,
      'season': season,
      'occasion': occasion,
      'material': material,
      'pattern': pattern,
      'isFavorite': isFavorite ? 1 : 0, // <<< THÊM DÒNG NÀY (lưu dưới dạng 1 hoặc 0)
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      imagePath: map['imagePath'],
      thumbnailPath: map['thumbnailPath'],
      closetId: map['closetId'],
      season: map['season'],
      occasion: map['occasion'],
      material: map['material'],
      pattern: map['pattern'],
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1, // <<< THÊM DÒNG NÀY (đọc từ 1 hoặc 0)
    );
  }

  @override
  List<Object?> get props => [
        id, name, category, color, imagePath, thumbnailPath, closetId,
        season, occasion, material, pattern, isFavorite // <<< THÊM isFavorite VÀO ĐÂY
      ];
}