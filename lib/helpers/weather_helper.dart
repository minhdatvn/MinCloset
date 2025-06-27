// lib/helpers/weather_helper.dart

class WeatherHelper {
  // Hàm tĩnh để có thể gọi trực tiếp mà không cần tạo instance
  static String getBackgroundImageForWeather(String? iconCode) {
    const String basePath = 'assets/images/weather/';

    // Nếu không có iconCode, trả về ảnh mặc định
    if (iconCode == null) {
      return '${basePath}default.webp';
    }

    // Ánh xạ iconCode từ API thời tiết sang tên file ảnh của bạn
    switch (iconCode) {
      case '01d': // clear sky day
      case '01n': // clear sky night
        return '${basePath}sunny.webp';

      case '02d': // few clouds day
      case '02n': // few clouds night
      case '03d': // scattered clouds day
      case '03n': // scattered clouds night
      case '04d': // broken clouds day
      case '04n': // broken clouds night
        return '${basePath}cloudy.webp';
      
      case '09d': // shower rain day
      case '09n': // shower rain night
      case '10d': // rain day
      case '10n': // rain night
        return '${basePath}rainy.webp';

      case '11d': // thunderstorm day
      case '11n': // thunderstorm night
        return '${basePath}storm.webp';
      
      case '13d': // snow day
      case '13n': // snow night
        return '${basePath}snow.webp';

      case '50d': // mist day
      case '50n': // mist night
        return '${basePath}mist.webp';
      
      default:
        return '${basePath}default.webp';
    }
  }
}