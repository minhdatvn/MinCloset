// lib/domain/models/validation_result.dart

class ValidationResult {
  final bool success;
  final String? errorMessage;
  final int? errorIndex;
  
  // THÊM 2 TRƯỜNG MỚI
  final String? errorCode; 
  final Map<String, dynamic>? data;

  ValidationResult.success()
      : success = true,
        errorMessage = null,
        errorIndex = null,
        errorCode = null, // Khởi tạo giá trị null
        data = null;

  // SỬA LẠI CONSTRUCTOR `failure`
  ValidationResult.failure(this.errorMessage, {this.errorIndex, this.errorCode, this.data})
      : success = false;
}