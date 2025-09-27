import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;
  bool _isInitialized = false;
  final Completer<void> _initializationCompleter = Completer<void>();

  NetworkInfo() {
    _init();
  }

  // Synchronous method to get the connectivity status
  bool get isConnected {
    if (!_isInitialized) {
      throw Exception(
          'ConnectionState has not been initialized yet. Call await ensureInitialized() first.');
    }
    return _isConnected;
  }

  // Asynchronous method to ensure initialization
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initializationCompleter.future;
    }
  }

  Future<void> _init() async {
    // Check the initial connectivity status
    await _checkConnectivity();

    // Mark as initialized
    _isInitialized = true;
    _initializationCompleter.complete();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) async {
      await _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    // Check if the device is connected to the internet
    var connectivityResult = await _connectivity.checkConnectivity();
    _isConnected = connectivityResult != ConnectivityResult.none;
  }
}
