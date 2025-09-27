import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/domain/models/matches_entity.dart';
import 'package:tranex_users/domain/models/models.dart';
import 'package:tranex_users/domain/models/trainee_model.dart';
import 'package:tranex_users/presentation/add_new_trainee_screen/view.dart';
import 'package:tranex_users/presentation/analysis_screen/analysis_match.dart';
import 'package:tranex_users/presentation/exercises/view.dart';
import 'package:tranex_users/presentation/fencing_match/fencing_match_view.dart';
import 'package:tranex_users/presentation/fencing_training/fencing_training_view_model.dart';
import 'package:tranex_users/presentation/login_screen/view/login_view.dart';
import 'package:tranex_users/presentation/matches_screen/view.dart';
import 'package:tranex_users/presentation/session_screen/session_view.dart';
import 'package:tranex_users/presentation/signup_screen/privacy_screen.dart';

import 'package:tranex_users/presentation/reset_password_screen/view/recover_password_view.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';

import 'package:tranex_users/presentation/trainees/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:tranex_users/presentation/fencing_training/fencing_view.dart';
import 'package:provider/provider.dart';
import '../main_screen/main_view.dart';
import '../profile_details_screen/view.dart';

class Routes {
  static const String root = "/";
  static const String loginScreen = "/login";
  static const String registerScreen = "/register";
  static const String privacyScreen = "/privacy";
  static const String recoverPasswordScreen = "/recoverPassword";
  static const String verifyCodeScreen = "/verifyCodeScreen";
  static const String changePasswordScreen = "/changePasswordScreen";
  static const String mainScreen = "/main";
  static const String searchScreen = '/searchScreen';
  static const String profileDetailsScreen = "/profileDetails";
  static const String settingScreen = "/setting";
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
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) {
            initLoginModule();
            return const LoginView();
          },
        );
      case Routes.recoverPasswordScreen:
        return MaterialPageRoute(
          builder: (_) {
            initRecoverPasswordModule();
            return const RecoverPasswordView();
          },
        );
      case Routes.inTrainingScreen:
        return MaterialPageRoute(
          builder: (_) {
            List arg = settings.arguments as List;
            initTraineesModule();
            return TrainingViewBar(
              device: arg[0] as DiscoveredDevice,
            );
          },
        );
      case FencingMatchView.routeName:
        return MaterialPageRoute(
          builder: (_) {
            initTraineesModule();
            return const FencingMatchView();
          },
        );
      case FencingTrainingView.routeName:
        return MaterialPageRoute(
          builder: (_) {
            final int arg = settings.arguments as int;
            initTraineesModule();
            return  Provider<FencingTrainingViewModel>(
                create: (_) => FencingTrainingViewModel()..start(),
            child: FencingTrainingView(
              device:arg,
            ));


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
      case ExercisesView.routeName:
        initExerciseModule();
        return MaterialPageRoute(
          builder: (_) => const ExercisesView(),
        );
      case Routes.privacyScreen:
        return MaterialPageRoute(builder: (_) => PrivacyPolicyScreen());
      case Routes.settingScreen:
        return MaterialPageRoute(builder: (_) => const AddNewTraineeView());
      case TrainersView.routeName:
        return MaterialPageRoute(builder: (_) => const TrainersView());

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
