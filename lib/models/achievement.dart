// lib/models/achievement.dart
import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String badgeId; // ID của huy hiệu sẽ nhận được khi hoàn thành
  final List<String> requiredQuestIds; // Danh sách ID các quest cần hoàn thành

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.badgeId,
    required this.requiredQuestIds,
  });

  @override
  List<Object> get props => [id, name, description, badgeId, requiredQuestIds];
}