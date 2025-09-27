import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  nfcReading,
  nfcWaiting,
  nfcSuccess,
  nfcError,
  started,
  stopped
}

class ConnectionStatus {
  final ConnectionState state;
  final String? message;
  final String? nfcUid;
  final int deviceNumber;
  final String deviceId;
  final double? speed;
  final int? direction;
  final bool? point;
  final int? timestamp;

  ConnectionStatus({
    required this.state,
    this.message,
    this.nfcUid,
    required this.deviceNumber,
    required this.deviceId,
    this.speed,
    this.direction,
    this.point,
    this.timestamp,
  });

  @override
  String toString() =>
      'ConnectionStatus(state: $state, message: $message, nfcUid: $nfcUid, deviceNumber: $deviceNumber, deviceId: $deviceId, speed: $speed, direction: $direction, point: $point, timestamp: $timestamp)';
}

class ConnectionRepository {
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  final Map<int, bool> _nfcPollingActive = {};
  final Map<int, bool> _pointPollingActive = {};
  final Map<int, bool> _speedPollingActive = {};
  final Map<int, String> _deviceIds = {};
  final Uuid _uuid = const Uuid();

  Stream<ConnectionStatus> get status => _statusController.stream;

  ConnectionRepository() {
    _logRequest('init', -1, 'ConnectionRepository initialized');
  }

  String _getIpAddress(int deviceNumber) {
    if (kDebugMode) return '192.168.1.${200 + deviceNumber}';
    return '192.168.12.${200 + deviceNumber}';
  }

  // دالة مساعدة لتسجيل الأحداث
  void _logRequest(String action, int deviceNumber, String details) {
    print('[ConnectionRepo][$action][Device $deviceNumber]: $details');
  }

  // دالة لإعادة المحاولة للطلبات
  Future<T> retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
    Duration retryInterval = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 5),
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxRetries) {
      try {
        return await request().timeout(timeout);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;
        _logRequest('retry', -1, 'Attempt $attempt/$maxRetries failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(retryInterval);
        }
      }
    }

    throw lastException ??
        Exception('Request failed after $maxRetries attempts');
  }

  Future<void> connect(int deviceNumber, String deviceType) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? _uuid.v4();
    _deviceIds[deviceNumber] = deviceId;
    _logRequest('connect', deviceNumber,
        'Sending request to $ipAddress, ID: $deviceId, Type: $deviceType');

    _statusController.add(ConnectionStatus(
      state: ConnectionState.connecting,
      deviceNumber: deviceNumber,
      deviceId: deviceId,
    ));

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/connect'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'device_id': deviceId,
            'device_type': deviceType,
          }),
        ),
      );

      _logRequest('connect', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.connected,
          message: json['message'] ?? 'Session started',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));

        startNfcPolling(deviceNumber);
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.disconnected,
          message: json['message'] ?? 'Connection failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('connect', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.disconnected,
        message: 'Connection error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  void startNfcPolling(int deviceNumber) {
    if (_nfcPollingActive[deviceNumber] == true) {
      _logRequest(
          'start_nfc_polling', deviceNumber, 'NFC polling already active');
      return;
    }
    _nfcPollingActive[deviceNumber] = true;
    _logRequest('start_nfc_polling', deviceNumber, 'Starting NFC polling');
    _pollNfc(deviceNumber);
  }

  void stopNfcPolling(int deviceNumber) {
    _nfcPollingActive[deviceNumber] = false;
    _logRequest('stop_nfc_polling', deviceNumber, 'NFC polling stopped');
  }

  void startPointPolling(int deviceNumber) {
    if (_pointPollingActive[deviceNumber] == true) {
      _logRequest(
          'start_point_polling', deviceNumber, 'Point polling already active');
      return;
    }
    _pointPollingActive[deviceNumber] = true;
    _logRequest('start_point_polling', deviceNumber, 'Starting point polling');
    _pollPoint(deviceNumber);
  }

  void stopPointPolling(int deviceNumber) {
    _pointPollingActive[deviceNumber] = false;
    _logRequest('stop_point_polling', deviceNumber, 'Point polling stopped');
  }

  void startSpeedPolling(int deviceNumber) {
    if (_speedPollingActive[deviceNumber] == true) {
      _logRequest(
          'start_speed_polling', deviceNumber, 'Speed polling already active');
      return;
    }
    _speedPollingActive[deviceNumber] = true;
    _logRequest('start_speed_polling', deviceNumber, 'Starting speed polling');
    _pollSpeed(deviceNumber);
  }

  void stopSpeedPolling(int deviceNumber) {
    _speedPollingActive[deviceNumber] = false;
    _logRequest('stop_speed_polling', deviceNumber, 'Speed polling stopped');
  }

  Future<void> _pollNfc(int deviceNumber) async {
    if (_nfcPollingActive[deviceNumber] != true) return;

    await _readNfc(deviceNumber);

    // إعادة الجدولة بعد تأخير
    Future.delayed(const Duration(milliseconds: 300), () {
      _pollNfc(deviceNumber);
    });
  }

  Future<void> _pollPoint(int deviceNumber) async {
    if (_pointPollingActive[deviceNumber] != true) return;

    await getPoint(deviceNumber);

    // إعادة الجدولة بعد تأخير
    Future.delayed(const Duration(milliseconds: 100), () {
      _pollPoint(deviceNumber);
    });
  }

  Future<void> _pollSpeed(int deviceNumber) async {
    if (_speedPollingActive[deviceNumber] != true) return;

    await getSpeed(deviceNumber);

    // إعادة الجدولة بعد تأخير
    Future.delayed(const Duration(milliseconds: 100), () {
      _pollSpeed(deviceNumber);
    });
  }

  Future<void> _readNfc(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('read_nfc', deviceNumber,
        'Sending request to $ipAddress, ID: $deviceId');

    _statusController.add(ConnectionStatus(
      state: ConnectionState.nfcReading,
      deviceNumber: deviceNumber,
      deviceId: deviceId,
    ));

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/read_nfc'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId}),
        ),
        maxRetries: 3,
        retryInterval: const Duration(seconds: 1),
        timeout: const Duration(seconds: 5),
      );

      _logRequest('read_nfc', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // if (kDebugMode) {
        //   json['status'] = 'ok';
        //   json['data']['uid'] = '00000000000000000000000000000000';
        //   print(json);
        // }
        if (json['status'] == 'ok') {
          _statusController.add(ConnectionStatus(
            state: ConnectionState.nfcSuccess,
            nfcUid: json['data']['uid'],
            deviceNumber: deviceNumber,
            deviceId: deviceId,
          ));
          stopNfcPolling(deviceNumber);
        } else if (json['status'] == 'waiting') {
          _statusController.add(ConnectionStatus(
            state: ConnectionState.nfcWaiting,
            message: 'Waiting for card',
            deviceNumber: deviceNumber,
            deviceId: deviceId,
          ));
        } else {
          _statusController.add(ConnectionStatus(
            state: ConnectionState.nfcError,
            message: json['message'] ?? 'Unknown error',
            deviceNumber: deviceNumber,
            deviceId: deviceId,
          ));
        }
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message:
              'HTTP ${response.statusCode}: ${json['message'] ?? 'Unknown error'}',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      _logRequest('read_nfc', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'NFC read error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> confirmNfc(int deviceNumber, bool success) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('confirm_nfc', deviceNumber,
        'Sending request to $ipAddress, success=$success');

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/confirm_nfc'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'device_id': deviceId,
            'success': success,
          }),
        ),
      );

      _logRequest('confirm_nfc', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        if (!success) {
          startNfcPolling(deviceNumber);
        } else {
          resetFlags(deviceNumber);
        }
        _statusController.add(ConnectionStatus(
          state: ConnectionState.connected,
          message: 'NFC confirmed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message: json['message'] ?? 'Confirm NFC failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('confirm_nfc', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'Confirm NFC error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> resetFlags(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('reset_flags', deviceNumber, 'Sending request to $ipAddress');

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/reset_flags'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId}),
        ),
      );

      _logRequest('reset_flags', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.connected,
          message: json['message'] ?? 'Flags reset',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message: json['message'] ?? 'Reset flags failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('reset_flags', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'Reset flags error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> start(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('start', deviceNumber, 'Sending request to $ipAddress');

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/start'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId}),
        ),
      );

      _logRequest('start', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.started,
          message: json['message'] ?? 'Session started',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message: json['message'] ?? 'Start failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('start', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'Start error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> stop(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('stop', deviceNumber, 'Sending request to $ipAddress');

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/stop'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId}),
        ),
      );

      _logRequest('stop', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.stopped,
          message: json['message'] ?? 'Session stopped',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message: json['message'] ?? 'Stop failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('stop', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'Stop error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> endSession(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('end_session', deviceNumber, 'Sending request to $ipAddress');

    stopNfcPolling(deviceNumber);
    stopPointPolling(deviceNumber);
    stopSpeedPolling(deviceNumber);

    try {
      final response = await retryRequest<http.Response>(
        () => http.post(
          Uri.parse('http://$ipAddress/end_session'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'device_id': deviceId}),
        ),
      );

      _logRequest('end_session', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.disconnected,
          message: json['message'] ?? 'Session ended',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.disconnected,
          message: json['message'] ?? 'End session failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('end_session', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.disconnected,
        message: 'End session error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> getSpeed(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('get_speed', deviceNumber, 'Sending request to $ipAddress');

    try {
      final response = await retryRequest<http.Response>(
        () => http.get(
          Uri.parse('http://$ipAddress/speed'),
          headers: {'Content-Type': 'application/json'},
        ),
        maxRetries: 3,
        retryInterval: const Duration(seconds: 1),
        timeout: const Duration(seconds: 5),
      );

      _logRequest('get_speed', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.connected,
          message:
              'Speed: ${json['data']['speed']}, Direction: ${json['data']['direction']}',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
          speed: json['data']['speed']?.toDouble(),
          direction: json['data']['direction']?.toInt(),
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message: json['message'] ?? 'Speed request failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('get_speed', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'Speed error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  Future<void> getPoint(int deviceNumber) async {
    String ipAddress = _getIpAddress(deviceNumber);
    String deviceId = _deviceIds[deviceNumber] ?? '';
    if (deviceId.isEmpty) return;
    _logRequest('get_point', deviceNumber, 'Sending request to $ipAddress');

    try {
      final response = await retryRequest<http.Response>(
        () => http.get(
          Uri.parse('http://$ipAddress/point'),
          headers: {'Content-Type': 'application/json'},
        ),
        maxRetries: 3,
        retryInterval: const Duration(seconds: 1),
        timeout: const Duration(seconds: 5),
      );

      _logRequest('get_point', deviceNumber,
          'Response: ${response.statusCode} ${response.body}');
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 && json['status'] == 'ok') {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.connected,
          message:
              'Point: ${json['data']['point']}${json['data']['timestamp'] != null ? ', Timestamp: ${json['data']['timestamp']}' : ''}',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
          point: json['data']['point'],
          timestamp: json['data']['timestamp']?.toInt(),
        ));
      } else {
        _statusController.add(ConnectionStatus(
          state: ConnectionState.nfcError,
          message: json['message'] ?? 'Point request failed',
          deviceNumber: deviceNumber,
          deviceId: deviceId,
        ));
      }
    } catch (e) {
      _logRequest('get_point', deviceNumber, 'Error after retries: $e');
      _statusController.add(ConnectionStatus(
        state: ConnectionState.nfcError,
        message: 'Point error after retries: $e',
        deviceNumber: deviceNumber,
        deviceId: deviceId,
      ));
    }
  }

  void dispose() {
    _logRequest('dispose', -1, 'Disposing ConnectionRepository');
    _nfcPollingActive.clear();
    _pointPollingActive.clear();
    _speedPollingActive.clear();
    _deviceIds.clear();
    _statusController.close();
  }
}
