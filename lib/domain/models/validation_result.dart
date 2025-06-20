// lib/domain/models/validation_result.dart

class ValidationResult {
  final bool success;
  final String? errorMessage;
  final int? errorIndex; // Dùng cho trường hợp batch, để biết lỗi ở món đồ nào

  ValidationResult.success()
      : success = true,
        errorMessage = null,
        errorIndex = null;

  ValidationResult.failure(this.errorMessage, {this.errorIndex})
      : success = false;
}