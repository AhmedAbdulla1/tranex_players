import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/domain/models/matches_entity.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:firesport_users/presentation/analysis_screen/analysis_match.dart';
import 'package:firesport_users/presentation/exercises/view.dart';
import 'package:firesport_users/presentation/fencing_match/fencing_match_view.dart';
import 'package:firesport_users/presentation/login_screen/view/login_view.dart';
import 'package:firesport_users/presentation/matches_screen/view.dart';
import 'package:firesport_users/presentation/privacy_policy/privacy_screen.dart';
import 'package:firesport_users/presentation/session_screen/session_view.dart';

import 'package:firesport_users/presentation/resources/string_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../main_screen/main_view.dart';
import '../profile_details_screen/view.dart';

class Routes {
  static const String root = "/";
  static const String loginScreen = "/login";
  static const String privacyScreen = "/privacy";
  static const String mainScreen = "/main";
  static const String searchScreen = '/searchScreen';
  static const String profileDetailsScreen = "/profileDetails";
  static const String exercisesScreen = "/exercises";
  static const String inTrainingScreen = '/inTraining';
  static const String fencingMatchScreen = '/fencingMatchScreen';
}

//
final AppPreferences _appPreferences = instance<AppPreferences>();

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        if (_appPreferences.isPressKeyLoginScreen()) {
          initMainModule();
          return MaterialPageRoute(builder: (_) => const MainView());
        } else {
          initLoginModule();
          return MaterialPageRoute(builder: (_) => const LoginView());
        }
      // case Routes.splashScreen:
      //   return MaterialPageRoute(builder: (_) => const SplashView());
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) {
            initLoginModule();
            return const LoginView();
          },
        );
      case Routes.inTrainingScreen:
        return MaterialPageRoute(
          builder: (_) {
            List arg = settings.arguments as List;
            initTraineesModule();
            return TrainingViewBar(
              device: arg[0] as DiscoveredDevice,
              fencing: arg[1] as bool,
            );
          },
        );
      case Routes.fencingMatchScreen:
        return MaterialPageRoute(
          builder: (_) {
            initTraineesModule();
            return FencingMatchView(
              device: settings.arguments as DiscoveredDevice,
            );
          },
        );

      case Routes.mainScreen:
        return MaterialPageRoute(builder: (_) {
          initMainModule();
          return const MainView();
        });
      case Routes.profileDetailsScreen:
        return MaterialPageRoute(builder: (_) {
          initProfileDetailsModule();
          return const ProfileDetailsView();
        });
      case Routes.exercisesScreen:
        initExerciseModule();
        return MaterialPageRoute(
          builder: (_) => const ExercisesView(),
        );
      case Routes.privacyScreen:
        return MaterialPageRoute(builder: (_) => PrivacyPolicyScreen());
      case MatchesView.routeName:
        return MaterialPageRoute(
          builder: (_) => MatchesView(
            traineeData: settings.arguments as TraineeData,
          ),
        );
      case FencingAnalysisView.routeName:
        List<dynamic> arg = settings.arguments as List;
        MatchEntity matchEntity = arg[0] as MatchEntity;
        TraineeData traineeData = arg[1] as TraineeData;
        return MaterialPageRoute(
          builder: (_) => FencingAnalysisView(
            matchEntity: matchEntity,
            traineeData: traineeData,
          ),
        );

      default:
        return unDefinedRoute();
    }
  }

  static Route unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(
            AppStrings.noRouteFound,
          ),
        ),
        body: const Center(
          child: Text(AppStrings.noRouteFound),
        ),
      ),
    );
  }
}
