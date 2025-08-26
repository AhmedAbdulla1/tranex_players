
import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/presentation/resources/assets_manager.dart';

final AppPreferences _appPreferences = instance<AppPreferences>();

class Constant {
  static const String baseurl = "https://doctorhunt.pythonanywhere.com/";
  static const String empty = "";
  static const String userData = 'userData';
  static const String exercises = "exercises";
  static const String trainees = 'trainees';
  static const String teams = 'teams';
  static const String devices = 'devices';

  static String token = _appPreferences.getToken();
  static const int zero = 0;
  static const Duration timeout = Duration(
      milliseconds: 60000); //this time by ms
  static const String image = ImageAssets.personal;
  static const List<String> imageList = [
    ImageAssets.deadliftToHigh,
    ImageAssets.rdlToHighPull,
    ImageAssets.singleArmHighPullLeft,
  ];
}





enum LoginMethod {
  email,
  google,
  apple,
  anonymous,
}