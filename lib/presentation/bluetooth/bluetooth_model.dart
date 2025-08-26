import 'dart:async';
import 'package:firesport_users/presentation/bluetooth/BluetoothDeviceListEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutterBlue;
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class BluetoothModel {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;

  // Controller لإرسال الأجهزة المكتشفة
  final _deviceController = BehaviorSubject<DiscoveredDevice?>.seeded(null);
  List<DiscoveredDevice> devices = [];
  bool isScanning = false;

  // Output Stream للأجهزة
  Stream<DiscoveredDevice?> get outDevice => _deviceController.stream;

  // طلب إذونات الـ Bluetooth
  Future<void> requestBluetoothPermissions() async {
    bool isBluetoothOn =
        await flutterBlue.FlutterBluePlus.adapterState.first == flutterBlue.BluetoothAdapterState.on;
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

  // بدء السكان
  void scanForDevices() {
    devices.clear();
    isScanning = true;

    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (!devices.any((d) => d.id == device.id)) {
        isScanning = false;
        print("Discovered device: ${device.name}");
        devices.add(device);
        _deviceController.add(device);
      }
    }, onError: (e) {
      print("Scan failed: $e");
      isScanning = false;
      _deviceController.addError(e);
    });
  }

  // إيقاف السكان
  void stopScan() {
    _scanSubscription.cancel();
    isScanning = false;
    // devices.clear();
    _deviceController.add(null);
  }

  Future<void> showDeviceDiscoveryDialog({
    required BuildContext context,
    required Function(DiscoveredDevice) onDeviceSelected,
  }) async {
    scanForDevices();

    showDialog(
      useSafeArea: true,
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
              print("Discovered device: ${snapshot.data?.name}");
              print(isScanning);

              if (isScanning) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "Scan failed: ${snapshot.error.toString()}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (!isScanning && devices.isEmpty) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "NO SCANNED RESULTS",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 300,
                width: 400,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16), // AppPadding.p16
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    return BluetoothDeviceListEntry(
                      device: devices[i],
                      onTap: () {
                        stopScan();
                        Navigator.pop(context);
                        print(devices);
                        onDeviceSelected(devices[i]);
                      },
                    );

                  },
                ),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.all(18), // AppPadding.p18
          actions: <Widget>[
            TextButton(
              onPressed: () {
                stopScan(); // وقف السكان القديم
                scanForDevices(); // ابدأ سكان جديد
              },
              child: Text(
                "Refresh",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            TextButton(
              onPressed: () {
                stopScan(); // وقف السكان
                Navigator.of(context).pop(); // إغلاق الـ Dialog
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

  // تنظيف الموارد
  void dispose() {
    _scanSubscription.cancel();
    _deviceController.close();
    devices.clear();
  }
}