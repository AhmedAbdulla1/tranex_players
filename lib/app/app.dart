import 'package:tranex_users/presentation/resources/routes_manager.dart';
import 'package:tranex_users/presentation/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:showcaseview/showcaseview.dart';

class MyApp extends StatelessWidget {
  MyApp._internal();

  static MyApp instance = MyApp._internal();

  factory MyApp() => instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ShowCaseWidget(
        builder: (context) => MaterialApp(
          navigatorObservers: [
            SentryNavigatorObserver(),
          ],
          debugShowCheckedModeBanner: false,
          title: 'Tranex',
          theme: getApplicationTheme(),
          navigatorKey: navigatorKey,
          onGenerateRoute: RouteGenerator.getRoute,
          initialRoute: Routes.root,
        ),
      ),
    );
  }
}
