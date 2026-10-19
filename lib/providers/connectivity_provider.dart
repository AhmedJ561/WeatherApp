import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool _hadOfflineEpisode = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOnline => _isOnline;

  bool get justReconnected => _hadOfflineEpisode && _isOnline;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    final result = await Connectivity().checkConnectivity();
    _updateStatus(result);

    _subscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) => r != ConnectivityResult.none);

    if (!wasOnline && _isOnline) {
      _hadOfflineEpisode = false;
    } else if (wasOnline && !_isOnline) {
      _hadOfflineEpisode = true;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
