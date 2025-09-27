import 'dart:async';
import 'package:tranex_users/presentation/bluetooth/BluetoothDeviceListEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutterBlue;
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class BluetoothModel {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;

  final _deviceController = BehaviorSubject<DiscoveredDevice?>.seeded(null);
  List<DiscoveredDevice> devices = [];
  bool isScanning = false;

  Stream<DiscoveredDevice?> get outDevice => _deviceController.stream;

  Future<void> requestBluetoothPermissions() async {
    bool isBluetoothOn =
        await flutterBlue.FlutterBluePlus.adapterState.first ==
            flutterBlue.BluetoothAdapterState.on;
    if (!isBluetoothOn) {
      await flutterBlue.FlutterBluePlus.turnOn();
    }
    if (await Permission.bluetooth.isDenied ||
        await Permission.location.isDenied) {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
    }
    if (await Permission.bluetooth.isPermanentlyDenied ||
        await Permission.location.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void scanForDevices() {
    devices.clear();
    isScanning = true;
    _deviceController.add(null); // Reset stream

    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (!devices.any((d) => d.id == device.id)) {
        devices.add(device);
        _deviceController.add(device);
        print("Discovered device: ${device.name} (${device.id})");
      }
    }, onError: (e) {
      print("Scan failed: $e");
      isScanning = false;
      _deviceController.addError(e);
    }, onDone: () {
      isScanning = false;
      _deviceController.add(null);
    });
  }

  void stopScan() {
    _scanSubscription.cancel();
    isScanning = false;
    _deviceController.add(null);
  }

  Future<void> showDeviceDiscoveryDialog({
    required BuildContext context,
    required Function(DiscoveredDevice) onDeviceSelected,
  }) async {
    await requestBluetoothPermissions();
    scanForDevices();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Device Available',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          content: StreamBuilder<DiscoveredDevice?>(
            stream: outDevice,
            builder: (context, snapshot) {
              print("StreamBuilder update: hasData=${snapshot.hasData}, "
                  "isScanning=$isScanning, devices=${devices.length}");

              if (isScanning && devices.isEmpty) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "Scan failed. Maybe Bluetooth is off.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (!isScanning && devices.isEmpty) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "No devices found.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 300,
                width: 400,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    return BluetoothDeviceListEntry(
                      device: devices[i],
                      onTap: () {
                        stopScan();
                        Navigator.pop(context);
                        onDeviceSelected(devices[i]);
                      },
                    );
                  },
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.all(18),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                stopScan();
                scanForDevices();
              },
              child: Text(
                "Refresh",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            TextButton(
              onPressed: () {
                stopScan();
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _scanSubscription.cancel();
    _deviceController.close();
    devices.clear();
  }
}