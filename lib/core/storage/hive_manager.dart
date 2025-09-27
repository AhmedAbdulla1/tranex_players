import 'dart:developer';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tranex_users/core/storage/hive_boxes.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';

class HiveManager {
  static bool _initialized = false;

  /// Initialize Hive with custom directory (AppData)
  static Future<void> init() async {
    if (_initialized) return;

    Directory appDataDir = await getApplicationSupportDirectory();
    Hive.init(appDataDir.path);
    log("Hive initialized at: ${appDataDir.path}");

    _registerAdapters();

    await _openBoxes();

    _initialized = true;
  }

  /// Register all Hive adapters here
  static void _registerAdapters() {
    Hive.registerAdapter(TraineeDataAdapter());
  }

  /// Open all required boxes here
  static Future<void> _openBoxes() async {
    await Hive.openBox(HiveBoxes.userDataBox);
  }

  /// Getter for userData box
  static Box get userDataBox => Hive.box(HiveBoxes.userDataBox);

  /// ✅ Put value
  static Future<void> put({
    required String boxName,
    required String key,
    required dynamic value,
  }) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
    log("Hive put: [$key] = $value in box: $boxName");
  }

  /// ✅ Get value
  static dynamic get({
    required String boxName,
    required String key,
  }) {
    final box = Hive.box(boxName);
    final value = box.get(key);
    log("Hive get: [$key] => $value from box: $boxName");
    return value;
  }

  /// ✅ Delete value
  static Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    final box = Hive.box(boxName);
    await box.delete(key);
    log("Hive delete: [$key] from box: $boxName");
  }

  /// ✅ Clear box
  static Future<void> clear({
    required String boxName,
  }) async {
    final box = Hive.box(boxName);
    await box.clear();
    log("Hive cleared: $boxName");
  }

  /// Close all boxes (on app exit for example)
  static Future<void> close() async {
    await Hive.close();
  }
}
