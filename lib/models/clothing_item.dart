// lib/models/clothing_item.dart
import 'package:equatable/equatable.dart';

class ClothingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final String color;
  final String imagePath;
  final String? thumbnailPath; // <<< THÊM MỚI
  final String closetId;
  final String? season;
  final String? occasion;
  final String? material;
  final String? pattern;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    this.thumbnailPath, // <<< THÊM MỚI
    required this.closetId,
    this.season,
    this.occasion,
    this.material,
    this.pattern,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    String? imagePath,
    String? thumbnailPath, // <<< THÊM MỚI
    String? closetId,
    String? season,
    String? occasion,
    String? material,
    String? pattern,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath, // <<< THÊM MỚI
      closetId: closetId ?? this.closetId,
      season: season ?? this.season,
      occasion: occasion ?? this.occasion,
      material: material ?? this.material,
      pattern: pattern ?? this.pattern,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath, // <<< THÊM MỚI
      'closetId': closetId,
      'season': season,
      'occasion': occasion,
      'material': material,
      'pattern': pattern,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      imagePath: map['imagePath'],
      thumbnailPath: map['thumbnailPath'], // <<< THÊM MỚI
      closetId: map['closetId'],
      season: map['season'],
      occasion: map['occasion'],
      material: map['material'],
      pattern: map['pattern'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        color,
        imagePath,
        thumbnailPath, // <<< THÊM MỚI
        closetId,
        season,
        occasion,
        material,
        pattern
      ];
}