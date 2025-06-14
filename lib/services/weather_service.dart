import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? 'API_KEY_NOT_FOUND';
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Map<String, dynamic>> getWeather(String city) async {
    final url = '$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=vi';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data.');
      }
    } catch (error) {
      throw Exception('Failed to connect to the weather service.');
    }
  }
}