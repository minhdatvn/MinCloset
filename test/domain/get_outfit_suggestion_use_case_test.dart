// test/domain/get_outfit_suggestion_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TẠO CÁC LỚP MOCK CHO DEPENDENCIES
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockWeatherRepository extends Mock implements WeatherRepository {}
class MockSuggestionRepository extends Mock implements SuggestionRepository {}

// TẠO CÁC LỚP MOCK CHO PLATFORM INTERFACE
// Thêm "with MockPlatformInterfaceMixin" để tuân thủ quy tắc test của package
class MockGeocodingPlatform extends Mock with MockPlatformInterfaceMixin implements GeocodingPlatform {}
class MockGeolocatorPlatform extends Mock with MockPlatformInterfaceMixin implements GeolocatorPlatform {
  // Cung cấp một giá trị mặc định cho các thuộc tính getter
  @override
  Stream<ServiceStatus> getServiceStatusStream() => const Stream.empty();
}

void main() {
  // Khai báo các biến
  late GetOutfitSuggestionUseCase useCase;
  late MockClothingItemRepository mockClothingRepo;
  late MockWeatherRepository mockWeatherRepo;
  late MockSuggestionRepository mockSuggestionRepo;
  
  late MockGeocodingPlatform mockGeocoding;
  late MockGeolocatorPlatform mockGeolocator;

  // Dữ liệu giả
  final tClothingItems = [
    const ClothingItem(id: '1', name: 'Áo khoác', category: 'Áo', color: 'Đen', imagePath: 'path', closetId: 'c1'),
  ];
  final tWeatherData = {'name': 'Da Nang', 'main': {'temp': 30.0}, 'weather': [{'description': 'nắng đẹp'}]};
  final tSuggestionMap = {'suggestion': 'Mặc áo khoác đen', 'reason': 'Vì trời lạnh'};

  // Hàm `setUp`
  setUp(() {
    mockClothingRepo = MockClothingItemRepository();
    mockWeatherRepo = MockWeatherRepository();
    mockSuggestionRepo = MockSuggestionRepository();
    mockGeocoding = MockGeocodingPlatform();
    mockGeolocator = MockGeolocatorPlatform();
    
    // Gán các instance mock cho platform interface
    GeocodingPlatform.instance = mockGeocoding;
    GeolocatorPlatform.instance = mockGeolocator;

    useCase = GetOutfitSuggestionUseCase(mockClothingRepo, mockWeatherRepo, mockSuggestionRepo);

    // Mặc định, giả lập các hàm trả về dữ liệu thành công
    when(() => mockClothingRepo.getAllItems()).thenAnswer((_) async => tClothingItems);
    when(() => mockWeatherRepo.getWeather(any())).thenAnswer((_) async => tWeatherData);
    when(() => mockWeatherRepo.getWeatherByCoords(any(), any())).thenAnswer((_) async => tWeatherData);
    when(() => mockSuggestionRepo.getOutfitSuggestion(weather: any(named: 'weather'), items: any(named: 'items'), cityName: any(named: 'cityName')))
        .thenAnswer((_) async => tSuggestionMap);
  });

  group('GetOutfitSuggestionUseCase', () {
    test('Nên trả về thông báo "thêm đồ" khi tủ đồ rỗng', () async {
      // Arrange
      when(() => mockClothingRepo.getAllItems()).thenAnswer((_) async => []);
      SharedPreferences.setMockInitialValues({'city_mode': 'auto'});

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['suggestion'], 'Hãy thêm đồ vào tủ để nhận gợi ý.');
    });

    test('Nên lấy thời tiết theo thành phố thủ công đã lưu', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'city_mode': 'manual',
        'manual_city_name': 'Hanoi',
        'manual_city_lat': 21.0,
        'manual_city_lon': 105.8,
      });
      final hanoiWeatherData = {'name': 'Hanoi', 'main': {'temp': 25.0}, 'weather': [{'description': 'se lạnh'}]};
      when(() => mockWeatherRepo.getWeatherByCoords(21.0, 105.8)).thenAnswer((_) async => hanoiWeatherData);
      
      // Act
      final result = await useCase.execute();

      // Assert
      verify(() => mockWeatherRepo.getWeatherByCoords(21.0, 105.8)).called(1);
      verifyNever(() => mockWeatherRepo.getWeather(any()));
      expect(result['weather'], hanoiWeatherData);
    });

    test('Nên lấy thời tiết tự động và dùng Geolocator khi ở chế độ auto', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'city_mode': 'auto'});
      
      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.always);
      when(() => mockGeolocator.getCurrentPosition(locationSettings: any(named: 'locationSettings')))
          .thenAnswer((_) async => Position(latitude: 16.0, longitude: 108.0, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0));
      
      when(() => mockGeocoding.placemarkFromCoordinates(16.0, 108.0)).thenAnswer((_) async => [Placemark(locality: 'Da Nang from GPS')]);
      
      final gpsWeatherData = {'name': 'Da Nang from GPS', 'main': {'temp': 32.0}, 'weather': [{'description': 'rất nắng'}]};
      when(() => mockWeatherRepo.getWeatherByCoords(16.0, 108.0)).thenAnswer((_) async => gpsWeatherData);

      // Act
      final result = await useCase.execute();

      // Assert
      verify(() => mockWeatherRepo.getWeatherByCoords(16.0, 108.0)).called(1);
      expect(result['weather'], gpsWeatherData);
      expect(result['weather']?['name'], 'Da Nang from GPS');
    });

     test('Nên dùng thành phố mặc định khi không có quyền vị trí', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'city_mode': 'auto'});

      when(() => mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(() => mockGeolocator.requestPermission()).thenAnswer((_) async => LocationPermission.denied);

      // Act
      await useCase.execute();

      // Assert
      verify(() => mockWeatherRepo.getWeather('Da Nang')).called(1);
      verifyNever(() => mockWeatherRepo.getWeatherByCoords(any(), any()));
    });
  });
}