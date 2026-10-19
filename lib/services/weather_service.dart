import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:weather_app/services/api_key.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org';

  Future<WeatherModel> fetchWeather(String city) async {
    try {
      final response = await http
          .get(Uri.parse(
              '$_baseUrl/data/2.5/forecast?q=$city&APPID=$apiKey'))
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['cod'] != '200') {
        throw WeatherException(
            data['message']?.toString() ?? 'City not found!');
      }

      return WeatherModel.fromJson(data, city);
    } on WeatherException {
      rethrow;
    } on SocketException {
      throw const WeatherException('No internet connection.');
    } on HttpException {
      throw const WeatherException('Could not reach the weather server.');
    } catch (e) {
      throw WeatherException(e.toString());
    }
  }

  Future<List<String>> fetchCitySuggestions(String query) async {
    if (query.length < 2) return [];
    try {
      final response = await http
          .get(Uri.parse(
              '$_baseUrl/geo/1.0/direct?q=$query&limit=5&appid=$apiKey'))
          .timeout(const Duration(seconds: 8));

      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<String>((item) => item['name'].toString())
          .toSet()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
