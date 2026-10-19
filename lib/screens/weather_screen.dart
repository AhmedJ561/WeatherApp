import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/connectivity_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/widgets/additional_info.dart';
import 'package:weather_app/widgets/hourly_forecast.dart';
import 'package:weather_app/widgets/no_internet_banner.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather('Islamabad');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getWeatherIcon(String condition) {
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
    final provider = context.watch<WeatherProvider>();

    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    final connectivityProvider = context.read<ConnectivityProvider>();
    if (isOnline && connectivityProvider.justReconnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.refresh();
      });
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black45),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search,
                      color: isDarkMode ? Colors.white54 : Colors.black38,
                      size: 20),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (query) => provider.fetchSuggestions(query),
                onSubmitted: (city) {
                  _searchController.clear();
                  provider.updateCity(city);
                },
              ),
            ),
            const SizedBox(width: 4),
            provider.isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.refresh(),
                    tooltip: 'Refresh',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(
        children: [
          const NoInternetBanner(),

          Expanded(
            child: SizedBox.expand(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        if (provider.citySuggestions.isNotEmpty)
                          Container(
                            color: isDarkMode ? Colors.black : Colors.white,
                            child: Column(
                              children: provider.citySuggestions.map((city) {
                                return ListTile(
                                  title: Text(
                                    city,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    _searchController.clear();
                                    provider.updateCity(city);
                                  },
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
                          child: _buildBody(provider, isDarkMode),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WeatherProvider provider, bool isDarkMode) {
    switch (provider.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return const SizedBox(
          height: 500,
          child: Center(child: CircularProgressIndicator.adaptive()),
        );

      case WeatherStatus.error:
        return SizedBox(
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => provider.refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );

      case WeatherStatus.success:
        final data = provider.weatherData!;
        return _buildWeatherContent(data, isDarkMode);
    }
  }

  Widget _buildWeatherContent(WeatherModel data, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.cityName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      '${data.tempCelsius.toStringAsFixed(2)} °C',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      _getWeatherIcon(data.condition),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.condition,
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

        const Text('Weather Forecast',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.hourlyForecasts.length,
            itemBuilder: (context, index) {
              final item = data.hourlyForecasts[index];
              return HourlyForecast(
                time: DateFormat.j().format(item.time),
                icon: _getWeatherIcon(item.condition),
                temperature: item.tempCelsius.toStringAsFixed(2),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        const Text('Additional Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AdditionalInfo(
                text: 'Humidity',
                icon: Icons.water_drop,
                value: data.humidity),
            AdditionalInfo(
                text: 'Wind', icon: Icons.air, value: data.windSpeed),
            AdditionalInfo(
                text: 'Pressure',
                icon: Icons.beach_access,
                value: data.pressure),
          ],
        ),
      ],
    );
  }
}
