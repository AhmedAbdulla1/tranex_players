// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/app/app.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/core/storage/hive_manager.dart';
import 'package:tranex_users/data/network/network_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkInfo().ensureInitialized();
  await HiveManager.init();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
    return;
  }

  await initAppModule();

  // تهيئة Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  // // تهيئة Instabug
  // try {
  //   await Instabug.init(
  //     token: dotenv.env['INSTABUG_TOKEN'] ?? '',
  //     invocationEvents: [InvocationEvent.floatingButton],
  //     debugLogsLevel: LogLevel.debug,
  //   );
  //   Instabug.setPrimaryColor(ColorManager.primary);
  //   final AppPreferences prefs = instance<AppPreferences>();
  //   if (!prefs.isNotFirstOpen()) {
  //     Instabug.showWelcomeMessageWithMode(WelcomeMessageMode.live);
  //     await prefs.setIsNotFirstOpen(true);
  //   }
  // } catch (e) {
  //   print('Error initializing Instabug: $e');
  // }
  //
  // // تهيئة NetworkInfo
  // try {
  //   await instance<NetworkInfo>().ensureInitialized();
  // } catch (e) {
  //   print('Error initializing NetworkInfo: $e');
  // }

  // تهيئة Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.debug = false; // قم بتعطيله في الإنتاج إذا لزم الأمر
      options.sendDefaultPii = true; // لتتبع معلومات المستخدم
      options.tracesSampleRate = 0.002;
      options.environment = 'production'; // أو 'development' حسب البيئة
      options.enableAutoSessionTracking = true;
      options.attachStacktrace = true;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: MyApp(),
      ),
    ),
  );
}
