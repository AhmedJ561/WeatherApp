import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weatherData;
  String? _errorMessage;
  String _cityName = 'Islamabad';
  List<String> _citySuggestions = [];
  bool _isRefreshing = false;


  WeatherStatus get status => _status;
  WeatherModel? get weatherData => _weatherData;
  String? get errorMessage => _errorMessage;
  String get cityName => _cityName;
  List<String> get citySuggestions => _citySuggestions;
  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _status == WeatherStatus.loading;


  Future<void> loadWeather(String city, {bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _status = WeatherStatus.loading;
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final data = await _service.fetchWeather(city);
      _weatherData = data;
      _cityName = city;
      _status = WeatherStatus.success;
      _errorMessage = null;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> updateCity(String city) async {
    _citySuggestions = [];
    notifyListeners();
    await loadWeather(city);
  }

  Future<void> refresh() async {
    await loadWeather(_cityName, isRefresh: true);
  }

  Future<void> fetchSuggestions(String query) async {
    if (query.length < 2) {
      _citySuggestions = [];
      notifyListeners();
      return;
    }
    final results = await _service.fetchCitySuggestions(query);
    _citySuggestions = results;
    notifyListeners();
  }

  void clearSuggestions() {
    _citySuggestions = [];
    notifyListeners();
  }
}
