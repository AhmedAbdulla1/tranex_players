import 'package:tranex_users/app/constant.dart';
import 'package:tranex_users/presentation/resources/language_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefsKeyLang = "PrefsKeyLang";
const String pressKeyOnBoardingScreen = 'PressKeyOnBoardingScreen';
const String pressKeyLoginScreen = 'PressKeyLoginScreen';
const String profileImageKey = 'profileImage';
const String cacheKey = 'cacheKey';
const String exerciseKey = "ExerciseKey";
const String trainingKey = "TrainingKey";
const String trainerKey = "TrainerKey";
const String token = "token";
const String coachId = "coachId";
const String firstOpen = 'firstOpen';
const String ipKey = 'ipKey';
const String exerciseImageKey = 'exerciseImage';
const String loginMethod = 'loginMethod';

class AppPreferences {
  final SharedPreferences _sharedPreferences;

  AppPreferences(this._sharedPreferences) {
    _sharedPreferences.setBool(cacheKey, true);
  }
  get sharedPreferences => _sharedPreferences;
  Future<String> getAppLanguage() async {
    String? language = _sharedPreferences.getString(prefsKeyLang);
    // ignore: unnecessary_null_comparison
    if (language != null && language.isNotEmpty) {
      return language;
    } else {
      return LanguageType.english.getValue();
    }
  }

  Future<void> setIsNotFirstOpen(bool t) async {
    await _sharedPreferences.setBool(firstOpen, t);
  }

  bool isNotFirstOpen() {
    return _sharedPreferences.getBool(firstOpen) ?? false;
  }

  Future setUpdateCache(bool updateCache) async {
    await _sharedPreferences.setBool(cacheKey, updateCache);
  }

  bool isUpdateCache() {
    return _sharedPreferences.getBool(cacheKey) ?? true;
  }

  Future setLoginMethod(LoginMethod method) async {
    await _sharedPreferences.setString(loginMethod, method.name);
  }

  String getLoginMethod() {
    return _sharedPreferences.getString(loginMethod) ?? LoginMethod.email.name;
  }

  Future<void> changeAppLanguage() async {
    String currentLang = await getAppLanguage();
    if (currentLang == LanguageType.arabic.getValue()) {
      _sharedPreferences.setString(
          prefsKeyLang, LanguageType.english.getValue());
    } else {
      _sharedPreferences.setString(
          prefsKeyLang, LanguageType.arabic.getValue());
    }
  }

  // Future<Locale> getLocale() async {
  //   String currentLang = await getAppLanguage();
  //   if (currentLang == LanguageType.arabic.getValue()) {
  //     return arabicLocale;
  //   } else {
  //     return englishLocale;
  //   }
  // }

  // onBoarding
  void setPressKeyOnBoardingScreen() {
    _sharedPreferences.setBool(pressKeyOnBoardingScreen, true);
  }

  void setProfileImage(String image) {
    _sharedPreferences.setString(profileImageKey, image);
  }

  Future<void> setWifiData(List<String> data) async {
    _sharedPreferences.setStringList(profileImageKey, data);
  }

  List<String>? getWifiData() {
    return _sharedPreferences.getStringList(
      profileImageKey,
    );
  }

  Future<void> getProfileImage(String image) async {
    _sharedPreferences.getString(profileImageKey);
  }

  Future<bool> isPressKeyOnBoardingScreen() async {
    return _sharedPreferences.getBool(pressKeyOnBoardingScreen) ?? false;
  }

  Future<void> setTraining(List<String> trainingData) async {
    _sharedPreferences.setStringList(trainingKey, trainingData);
  }

  List<String>? getTraining() {
    return _sharedPreferences.getStringList(trainingKey);
  }

  //set trainer data


  List<String>? getTrainee() {
    return _sharedPreferences.getStringList(trainerKey);
  }

  //login
  Future<void> setPressKeyLoginScreen() async {
    _sharedPreferences.setBool(pressKeyLoginScreen, true);
  }

  bool isPressKeyLoginScreen() {
    return _sharedPreferences.getBool(pressKeyLoginScreen) ?? false;
  }

  // sign up screen
  Future<void> setPressKeySignupScreen() async {
    _sharedPreferences.setBool(pressKeyLoginScreen, true);
  }

  Future<bool> isPressKeySignupScreen() async {
    return _sharedPreferences.getBool(pressKeyLoginScreen) ?? false;
  }

  //token
  Future<void> setUid(String t) async {
    _sharedPreferences.setString(token, t);
  }

  String getUid() {
    return _sharedPreferences.getString(token) ?? '';
  }
  //token
  Future<void> setCoachId(int t) async {
    _sharedPreferences.setInt(coachId, t);
  }

  int getCoachId() {
    return _sharedPreferences.getInt(coachId) ?? 0;
  }

  // logout
  Future<void> logout() {
    _sharedPreferences.remove(token);
    _sharedPreferences.remove(trainingKey);
    _sharedPreferences.remove(coachId);
    return _sharedPreferences.remove(pressKeyLoginScreen);
  }



  Future<void> setIp(String ip) async {
    await _sharedPreferences.setString(ipKey, ip);
  }

  Future<void> setExerciseImage(String image) async {
    await _sharedPreferences.setString(exerciseImageKey, image);
  }

  String? getExerciseImage() {
    return _sharedPreferences.getString(exerciseImageKey);
  }

  String getIp() {
    return _sharedPreferences.getString(ipKey) ?? "";
  }
}
