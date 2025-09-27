import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter/services.dart';

class BleDeviceConnector {
  BleDeviceConnector({
    required FlutterReactiveBle ble,
    required void Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage,
        _deviceConnectionController = StreamController<ConnectionStateUpdate>.broadcast();

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  final StreamController<ConnectionStateUpdate> _deviceConnectionController;
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  StreamSubscription<ConnectionStateUpdate>? _connection;
  String? _currentDeviceId;

  /// يتصل بالجهاز ويُكمِل الـ Future فقط عند الوصول لحالة connected.
  /// يعمل retry تلقائي في حال فشل service discovery.
  Future<void> connectAndWait(
      String deviceId, {
        Duration timeout = const Duration(seconds: 8),
        int maxRetries = 3,
        Duration initialBackoff = const Duration(milliseconds: 300),
      }) async {
    _currentDeviceId = deviceId;

    var attempt = 0;
    while (attempt < maxRetries) {
      attempt++;
      try {
        await _connectOnceAndWait(deviceId, timeout: timeout);
        return; // success
      } on PlatformException catch (e) {
        _logMessage(
            'connect attempt $attempt failed with PlatformException: code=${e.code}, message=${e.message}');
        if (e.code == 'service_discovery_failure') {
          await _safeCancelConnection();
          final backoff = initialBackoff * attempt;
          _logMessage('retrying after backoff: ${backoff.inMilliseconds}ms');
          await Future.delayed(backoff);
          continue;
        }
        rethrow;
      } catch (e) {
        _logMessage('connect attempt $attempt failed with $e');
        final backoff = initialBackoff * attempt;
        await _safeCancelConnection();
        await Future.delayed(backoff);
      }
    }

    throw PlatformException(
      code: 'service_discovery_failure',
      message: 'Failed to connect after $maxRetries attempts',
    );
  }

  /// تفصل الاتصال الحالي (إن وُجد)
  Future<void> disconnect() async {
    if (_currentDeviceId != null) {
      _logMessage('disconnecting from device: $_currentDeviceId');
    }
    await _safeCancelConnection();
    if (_currentDeviceId != null) {
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: _currentDeviceId!,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
    _currentDeviceId = null;
  }

  Future<void> dispose() async {
    await _safeCancelConnection();
    await _deviceConnectionController.close();
  }

  // ------------------ internals ------------------

  Future<void> _connectOnceAndWait(String deviceId, {required Duration timeout}) async {
    _logMessage('Start connecting to $deviceId');

    // اتأكد مفيش اتصال قديم
    await _safeCancelConnection();

    final completer = Completer<void>();

    _connection = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: timeout,
    )
        .listen(
          (update) {
        _logMessage('ConnectionState for device $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);

        if (update.connectionState == DeviceConnectionState.connected && !completer.isCompleted) {
          completer.complete();
        } else if (update.connectionState == DeviceConnectionState.disconnected &&
            !completer.isCompleted) {
          completer.completeError(PlatformException(
            code: 'disconnected',
            message: 'Disconnected before becoming connected',
          ));
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(PlatformException(
            code: 'done_without_connected',
            message: 'Stream closed before connected',
          ));
        }
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  Future<void> _safeCancelConnection() async {
    try {
      await _connection?.cancel();
    } catch (e) {
      _logMessage('Error cancelling connection subscription: $e');
    } finally {
      _connection = null;
    }
  }
}
