// lib/providers/home_page_state.dart

// Một lớp đơn giản, không có logic, chỉ để chứa dữ liệu.
// Dùng `final` để đảm bảo trạng thái là bất biến (immutable).
class HomePageState {
  final bool isLoading;
  final String? suggestion;
  final Map<String, dynamic>? weather;
  final String? errorMessage;

  // Constructor
  const HomePageState({
    this.isLoading = true,
    this.suggestion,
    this.weather,
    this.errorMessage,
  });

  // Hàm copyWith giúp tạo một bản sao của trạng thái hiện tại
  // nhưng với một vài giá trị được cập nhật. Đây là cách làm tiêu chuẩn.
  HomePageState copyWith({
    bool? isLoading,
    String? suggestion,
    Map<String, dynamic>? weather,
    String? errorMessage,
    bool clearError = false, // Thêm một cờ để xóa lỗi
  }) {
    return HomePageState(
      isLoading: isLoading ?? this.isLoading,
      suggestion: suggestion ?? this.suggestion,
      weather: weather ?? this.weather,
      // Nếu clearError là true thì đặt errorMessage là null
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}