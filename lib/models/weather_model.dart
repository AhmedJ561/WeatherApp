class HourlyForecastItem {
  final DateTime time;
  final String condition;
  final double tempCelsius;

  const HourlyForecastItem({
    required this.time,
    required this.condition,
    required this.tempCelsius,
  });
}

class WeatherModel {
  final String cityName;
  final double tempCelsius;
  final String condition;
  final String humidity;
  final String windSpeed;
  final String pressure;
  final List<HourlyForecastItem> hourlyForecasts;

  const WeatherModel({
    required this.cityName,
    required this.tempCelsius,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.hourlyForecasts,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String cityName) {
    final current = json['list'][0];
    final tempKelvin = (current['main']['temp'] as num).toDouble();

    final List<HourlyForecastItem> forecasts = [];
    for (int i = 1; i <= 5; i++) {
      final item = json['list'][i];
      forecasts.add(HourlyForecastItem(
        time: DateTime.parse(item['dt_txt']),
        condition: item['weather'][0]['main'].toString(),
        tempCelsius: (item['main']['temp'] as num).toDouble() - 273.15,
      ));
    }

    return WeatherModel(
      cityName: cityName,
      tempCelsius: tempKelvin - 273.15,
      condition: current['weather'][0]['main'].toString(),
      humidity: current['main']['humidity'].toString(),
      windSpeed: current['wind']['speed'].toString(),
      pressure: current['main']['pressure'].toString(),
      hourlyForecasts: forecasts,
    );
  }
}
