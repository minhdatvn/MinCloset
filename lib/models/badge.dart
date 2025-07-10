// lib/models/badge.dart
import 'package:equatable/equatable.dart';

class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imagePath; // Đường dẫn đến ảnh của huy hiệu

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  @override
  List<Object> get props => [id, name, description, imagePath];
}