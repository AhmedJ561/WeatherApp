import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/connectivity_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return AnimatedSlide(
      offset: isOnline ? const Offset(0, -1) : Offset.zero,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isOnline ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Material(
          elevation: 4,
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade700,
                  Colors.orange.shade700,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No internet connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Showing last known data',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    context.read<WeatherProvider>().refresh();
                  },
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 16),
                  label: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
