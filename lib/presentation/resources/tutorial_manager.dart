import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/di.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class TutorialManager {
  static final TutorialManager _instance = TutorialManager._internal();
  factory TutorialManager() => _instance;
  TutorialManager._internal();

  // مفاتيح لكل عنصر في الشاشات
  final GlobalKey homeButtonKey = GlobalKey();
  final GlobalKey trainingButtonKey = GlobalKey();
  final Map<String, List<GlobalKey>> tutorialSteps ={};
  final GlobalKey homeFabKey = GlobalKey();
  final GlobalKey settingsButtonKey = GlobalKey();



  // بدء المود التعليمي
  Future<void> startTutorial(BuildContext context) async {
    AppPreferences prefs = instance<AppPreferences>();
    bool hasSeenTutorial = prefs.sharedPreferences.setBool('hasSeenTutorial') ?? false;

    if (!hasSeenTutorial) {
      // Skip tutorial for login and registration screens
      if (ModalRoute.of(context)!.settings.name == '/login' || ModalRoute.of(context)!.settings.name == '/register') {
        return;
      }

      // Add steps for training screen
      tutorialSteps['training'] = [trainingButtonKey];
      // Start tutorial from the training screen
      ShowCaseWidget.of(context).startShowCase(tutorialSteps['training']!);
      await prefs.sharedPreferences.setBool('hasSeenTutorial', true);
    }
      // إضافة الخطوات لكل شاشة
      tutorialSteps['home'] = [homeButtonKey, homeFabKey];
      tutorialSteps['settings'] = [settingsButtonKey];

      // بدء المود من الشاشة الرئيسية
      ShowCaseWidget.of(context).startShowCase(tutorialSteps['home']!);
      await prefs.sharedPreferences.setBool('hasSeenTutorial', true);
    }

  // الانتقال إلى الشاشة التالية
  void proceedToNextScreen(BuildContext context, String nextScreen) {
    if (tutorialSteps.containsKey(nextScreen)) {
      Navigator.pushNamed(context, '/$nextScreen').then((_) {
        // بدء المود للشاشة الجديدة بعد التنقل
        ShowCaseWidget.of(context).startShowCase(tutorialSteps[nextScreen]!);
      });
    }
  }

  // إعادة تشغيل المود التعليمي
  Future<void> resetTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', false);
  }
}