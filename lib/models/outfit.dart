// lib/models/outfit.dart
import 'package:equatable/equatable.dart';

class Outfit extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final String itemIds;

  const Outfit({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.itemIds,
  });

  // <<< THÊM PHƯƠNG THỨC `copyWith`
  Outfit copyWith({
    String? id,
    String? name,
    String? imagePath,
    String? itemIds,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      itemIds: itemIds ?? this.itemIds,
    );
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      itemIds: map['itemIds'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'itemIds': itemIds,
    };
  }

  // <<< THÊM `props` CHO EQUATABLE
  @override
  List<Object?> get props => [id, name, imagePath, itemIds];
}