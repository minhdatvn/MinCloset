// lib/domain/failures/failures.dart

import 'package:equatable/equatable.dart';

// Lớp trừu tượng, là lớp cha cho tất cả các loại lỗi có thể dự đoán được
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Lỗi liên quan đến máy chủ (API trả về lỗi 4xx, 5xx)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Lỗi liên quan đến kết nối mạng (không có internet)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Lỗi liên quan đến CSDL cục bộ (lưu/đọc cache thất bại)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Lỗi chung cho các trường hợp không xác định (sau khi đã báo Sentry)
class GenericFailure extends Failure {
  const GenericFailure(super.message);
}