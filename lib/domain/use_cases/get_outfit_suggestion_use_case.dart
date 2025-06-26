import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetOutfitSuggestionUseCase {
  final ClothingItemRepository _clothingItemRepo;
  final WeatherRepository _weatherRepo;
  final SuggestionRepository _suggestionRepo;
  final OutfitRepository _outfitRepo;

  GetOutfitSuggestionUseCase(
    this._clothingItemRepo,
    this._weatherRepo,
    this._suggestionRepo,
    this._outfitRepo, 
  );

  Future<Map<String, dynamic>> getWeatherForSuggestion() async {
    final prefs = await SharedPreferences.getInstance();
    final cityModeString = prefs.getString('city_mode') ?? 'auto';
    final cityMode = CityMode.values.byName(cityModeString);

    Map<String, dynamic> weatherData;
    String displayName = 'Da Nang'; // Tên hiển thị mặc định

    try {
      if (cityMode == CityMode.manual) {
        final lat = prefs.getDouble('manual_city_lat');
        final lon = prefs.getDouble('manual_city_lon');
        final manualCityName = prefs.getString('manual_city_name');

        if (lat != null && lon != null && manualCityName != null) {
          logger.i('Get weather by saved coordinates: ($lat, $lon)');
          weatherData = await _weatherRepo.getWeatherByCoords(lat, lon);
          displayName = manualCityName;
        } else {
          logger.w('Manual location data missing, reverting to default.');
          weatherData = await _weatherRepo.getWeather(displayName);
        }
      } else { // Chế độ tự động
        logger.i('Getting weather by auto-detecting location…');
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are denied.');
        }
        
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        weatherData = await _weatherRepo.getWeatherByCoords(
            position.latitude, position.longitude);
            
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        
        // Ưu tiên lấy administrativeArea (tên tỉnh/thành phố), nếu không có mới lấy locality (quận/huyện)
        displayName = placemarks.first.administrativeArea ?? placemarks.first.locality ?? displayName;
      }
    } catch (e, s) {
      logger.e("Failed to load weather for suggestions, using default.", error: e, stackTrace: s);
      // Báo cáo lỗi không lấy được thời tiết lên Sentry
      await Sentry.captureException(e, stackTrace: s);
      // Nếu có bất kỳ lỗi nào ở trên, chuyển sang dùng thành phố mặc định
      weatherData = await _weatherRepo.getWeather(displayName);
    }
    
    // Đảm bảo gán tên hiển thị trước khi trả về
    weatherData['name'] = displayName;
    return weatherData;
  }

  Future<Map<String, dynamic>> execute() async {
    // 1. Lấy SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // 2. Lấy toàn bộ vật phẩm và các bộ đồ
    final allItems = await _clothingItemRepo.getAllItems();
    final allOutfits = await _outfitRepo.getOutfits();

    // 3. KIỂM TRA ĐIỀU KIỆN TỐI THIỂU
    final topwearCount = allItems.where((item) => item.category.startsWith('Áo')).length;
    final bottomwearCount = allItems.where((item) => item.category.startsWith('Quần') || item.category.startsWith('Váy')).length;

    if (topwearCount < 3 || bottomwearCount < 3) {
      throw Exception('Please add at least 3 tops and 3 bottoms/skirts to your wardrobe to receive suggestions.');
    }

    // 4. Lấy dữ liệu thời tiết (tái sử dụng hàm cũ)
    final weatherData = await getWeatherForSuggestion();

    // 5. Lấy thông tin người dùng từ SharedPreferences
    final gender = prefs.getString('user_gender') ?? 'Not specified';
    final userStyle = prefs.getStringList('user_styles')?.join(', ') ?? 'Any style';
    final favoriteColors = prefs.getStringList('user_favorite_colors')?.join(', ') ?? 'Any color';

    // 6. Phân loại "Set Outfits" và "Vật phẩm lẻ"
    final setOutfits = allOutfits.where((o) => o.isFixed).toList();
    final fixedItemIds = setOutfits.expand((o) => o.itemIds.split(',')).toSet();
    final individualItems = allItems.where((item) => !fixedItemIds.contains(item.id)).toList();

    // 7. Định dạng chuỗi để gửi cho AI
    final setOutfitsString = setOutfits.map((outfit) {
      final itemNames = outfit.itemIds.split(',').map((id) {
        return allItems.firstWhere((item) => item.id == id, orElse: () => ClothingItem(id: '', name: 'Unknown Item', category: '', color: '', imagePath: '', closetId: '')).name;
      }).toList();
      return '- Set "${outfit.name}": Gồm [${itemNames.join(', ')}]';
    }).join('\n');

    final wardrobeString = individualItems.map((item) => '- ${item.name} (${item.category}, màu ${item.color})').join('\n');

    // Gọi service để lấy JSON thô từ AI
    final suggestionJson = await _suggestionRepo.getOutfitSuggestion(
      weather: weatherData,
      cityName: weatherData['name'] as String,
      gender: gender,
      userStyle: userStyle,
      favoriteColors: favoriteColors,
      setOutfitsString: setOutfitsString.isNotEmpty ? setOutfitsString : "Không có",
      wardrobeString: wardrobeString.isNotEmpty ? wardrobeString : "Không có",
    );

    // <<< LOGIC MỚI: XỬ LÝ JSON VÀ TẠO SUGGESTIONRESULT >>>
    final compositionMap = suggestionJson['outfit_composition'] as Map<String, dynamic>? ?? {};
    final Map<String, ClothingItem?> structuredComposition = {};

    // Duyệt qua từng slot (topwear, bottomwear,...) mà AI trả về
    compositionMap.forEach((slot, itemName) {
      if (itemName != null) {
        // Tìm vật phẩm trong `allItems` có tên tương ứng
        final foundItem = allItems.cast<ClothingItem?>().firstWhere(
          (item) => item?.name == itemName,
          orElse: () => null,
        );
        structuredComposition[slot] = foundItem;
      } else {
        structuredComposition[slot] = null;
      }
    });

    final result = SuggestionResult(
      outfitName: suggestionJson['outfit_name'] as String? ?? 'Stylish Outfit',
      reason: suggestionJson['reason'] as String? ?? 'A great choice for today!',
      composition: structuredComposition,
    );

    // Giờ đây hàm execute trả về một đối tượng có cấu trúc rõ ràng
    return {
      'weather': weatherData,
      'suggestionResult': result,
    };
  }
}