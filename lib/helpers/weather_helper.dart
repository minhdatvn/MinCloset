// lib/helpers/weather_helper.dart
import 'dart:math';

class WeatherHelper {
  // Trình tạo số ngẫu nhiên
  static final _random = Random();

  // Ánh xạ từ mã thời tiết sang số lượng ảnh có sẵn
  // <<< QUAN TRỌNG: Hãy cập nhật các con số này cho đúng với số lượng ảnh bạn có >>>
  static const Map<String, int> _imageCounts = {
    '01d': 1, // Trời nắng
    '04d': 2, // Nhiều mây
    '10d': 2, // Mưa
    '11d': 2, // Bão
    '13d': 1, // Tuyết
    '50d': 1, // Sương mù
    'default': 1,
  };

  // Hàm private để nhóm các mã thời tiết tương tự nhau
  static String _mapIconToCode(String? iconCode) {
    if (iconCode == null) return 'default';

    switch (iconCode) {
      case '01d':
      case '01n':
        return '01d'; // Nắng/Quang

      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return '04d'; // Các loại mây

      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return '10d'; // Các loại mưa

      case '11d':
      case '11n':
        return '11d'; // Bão

      case '13d':
      case '13n':
        return '13d'; // Tuyết

      case '50d':
      case '50n':
        return '50d'; // Sương mù

      default:
        return 'default';
    }
  }

  // Hàm chính đã được viết lại hoàn toàn
  static String getBackgroundImageForWeather(String? iconCode) {
    const String basePath = 'assets/images/weather_backgrounds/';

    // 1. Lấy mã đại diện (ví dụ: '02d', '03n' đều trở thành '04d')
    final String representativeCode = _mapIconToCode(iconCode);

    // 2. Lấy số lượng ảnh cho mã đó từ Map, nếu không có thì mặc định là 1
    final int count = _imageCounts[representativeCode] ?? 1;

    // 3. Tạo một số ngẫu nhiên từ 1 đến `count`
    //    _random.nextInt(count) sẽ tạo số từ 0 -> (count-1)
    final int randomIndex = _random.nextInt(count) + 1;

    // 4. Dựng lại đường dẫn file hoàn chỉnh
    final path = '$basePath${representativeCode}_$randomIndex.webp';
    
    // 5. Trả về đường dẫn. Chúng ta sẽ thêm một bước kiểm tra nhỏ ở đây
    //    để phòng trường hợp file không tồn tại, sẽ trả về ảnh mặc định.
    //    Lưu ý: cơ chế này cần file `AssetManifest.json` nên không thể
    //    kiểm tra trực tiếp, nhưng đây là một ví dụ về cách làm an toàn hơn.
    //    Trong trường hợp này, chúng ta giả định file luôn tồn tại.
    return path;
  }
}