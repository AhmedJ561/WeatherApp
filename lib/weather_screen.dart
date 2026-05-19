import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/api_key.dart';
import 'package:weather_app/hourly_forecast.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  String cityName = "Islamabad";
  final TextEditingController _searchController = TextEditingController();
  List<String> citySuggestions = [];
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(cityName);
  }

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    try {
      final result = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$apiKey"));
      final data = jsonDecode(result.body);

      if (data['cod'] != "200") {
        throw "City not found!";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> fetchCitySuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        citySuggestions = [];
      });
      return;
    }

    final response = await http.get(Uri.parse(
        "http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey"));
    final List data = jsonDecode(response.body);

    setState(() {
      citySuggestions =
          data.map<String>((item) => item['name']).toSet().toList();
    });
  }

  void updateCity(String selectedCity) {
    setState(() {
      cityName = selectedCity;
      citySuggestions = [];
      _searchController.clear();
      weather = getCurrentWeather(cityName);
    });
  }

  void refreshWeather() async {
    setState(() {
      isRefreshing = true;
    });
    try {
      weather = getCurrentWeather(cityName);
      await weather;
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return Icons.filter_drama;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Search city...',
            hintStyle:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black45),
            border: InputBorder.none,
          ),
          onChanged: fetchCitySuggestions,
          onSubmitted: updateCity,
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshWeather,
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  if (citySuggestions.isNotEmpty)
                    Container(
                      color: isDarkMode ? Colors.black : Colors.white,
                      child: Column(
                        children: citySuggestions.map((city) {
                          return ListTile(
                            title: Text(
                              city,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () => updateCity(city),
                            shape: Border(
                              bottom: BorderSide(
                                color: isDarkMode
                                    ? Colors.white30
                                    : Colors.black26,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder(
                      future: weather,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 500, // optional: can remove this
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        }

                        final data = snapshot.data;
                        final currentTempData = data!['list'][0];
                        final currentTemp = currentTempData['main']['temp'];
                        final skyState =
                            currentTempData['weather'][0]['main'].toString();
                        final String humidity =
                            currentTempData['main']['humidity'].toString();
                        final String windSpeed =
                            currentTempData['wind']['speed'].toString();
                        final String airPressure =
                            currentTempData['main']['pressure'].toString();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cityName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                elevation: 10,
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Text(
                                          "${(currentTemp - 273.15).toStringAsFixed(2)} °C",
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Icon(
                                          getWeatherIcon(skyState),
                                          size: 64,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          skyState,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text("Weather Forecast",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  final time = DateTime.parse(
                                      data['list'][index + 1]['dt_txt']);
                                  final weatherCondition = data['list']
                                          [index + 1]['weather'][0]['main']
                                      .toString();
                                  return HourlyForecast(
                                    time: DateFormat.j().format(time),
                                    icon: getWeatherIcon(weatherCondition),
                                    temperature: data['list'][index + 1]['main']
                                            ['temp']
                                        .toString(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text("Additional Information",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AdditionalInfo(
                                    text: "Humidity",
                                    icon: Icons.water_drop,
                                    value: humidity),
                                AdditionalInfo(
                                    text: "Wind",
                                    icon: Icons.air,
                                    value: windSpeed),
                                AdditionalInfo(
                                    text: "Pressure",
                                    icon: Icons.beach_access,
                                    value: airPressure),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
