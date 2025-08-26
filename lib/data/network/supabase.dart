import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firesport_users/app/app_prefs.dart';
import 'package:firesport_users/app/constant.dart';
import 'package:firesport_users/app/di.dart';
import 'package:firesport_users/data/mapper/mapper.dart';
import 'package:firesport_users/data/network/requests.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAppClient {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final SupabaseClient _supabase = Supabase.instance.client;

  // تسجيل الدخول باستخدام الإيميل وكلمة المرور
  Future<int> loginWithEmail(LoginRequest loginRequest) async {
    return 0;
  }

  // تسجيل حساب جديد باستخدام الإيميل وكلمة المرور
  Future<int> register(RegisterRequest registerRequest) async {
    final response = await _supabase.auth.signUp(
      email: registerRequest.email,
      password: registerRequest.password,
    );
    await _supabase.auth.updateUser(
      UserAttributes(data: {'display_name': registerRequest.name}),
    );
    final newCoachResponse = await _supabase
        .from('coaches')
        .insert({
          'auth_id': response.user!.id,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('coach_id')
        .single();

    final int newCoachId = newCoachResponse['coach_id'] as int;
    log('Added new coach with auth_id:  and coach_id: $newCoachId');
    return newCoachId;
  }

  // Future<User> loginWithGoogle() async {
  //   final googleSignIn = await _supabase.auth.signInWithOAuth(
  //     OAuthProvider.google,
  //     redirectTo: 'io.supabase.firesport://login-callback/',
  //   );
  //   _appPreferences.setLoginMethod(LoginMethod.google);
  //   return _supabase.auth.currentUser!;
  // }

  Future<User?> loginWithGoogle() async {
    try {
      /// TODO: update the Web client ID with your own.
      ///
      /// Web Client ID that you registered with Google Cloud.
      const webClientId =
          '144165828319-43c81o3d5q7b5h06co5m1nb08tencfen.apps.googleusercontent.com';

      /// TODO: update the iOS client ID with your own.
      ///
      final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId,
          signInOption: SignInOption.standard,
          clientId:
              "144165828319-vl79u4lm2oljjmfql613fn4ullnb1jn8.apps.googleusercontent.com",
          scopes: [
            'email',
          ]);
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      print('Access Token: $accessToken');
      print('ID Token: $idToken');
      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        print('تم تسجيل الدخول بنجاح: ${response.user!.email}');
        return response.user!;
      } else {
        print('فشل في تسجيل الدخول في Supabase');
      }
    } catch (error) {
      print('خطأ أثناء تسجيل الدخول: $error');
    }
  }

  // تسجيل الدخول باستخدام Apple
  Future<User> loginWithApple() async {
    final appleSignIn = await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.firesport://login-callback/',
    );
    _appPreferences.setLoginMethod(LoginMethod.apple);
    return _supabase.auth.currentUser!;
  }

  // تسجيل الدخول كمستخدم مجهول
  Future<User> registerAnonymous() async {
    final response = await _supabase.auth.signInAnonymously();
    _appPreferences.setLoginMethod(LoginMethod.anonymous);
    return response.user!;
  }

  // جلب المستخدم الحالي
  TraineeData getUser() {
      final Map<String,dynamic> user = jsonDecode(_appPreferences.getUser());
      return user.traineeDataToDomain();
  }

  Future<int?> getCoachId() async {
    try {
      final authId =
          _supabase.auth.currentUser?.id; // جلب auth_id من المستخدم الحالي
      if (authId == null) {
        log('No authenticated user found.');
        return null;
      }

      // استعلم عن coach_id باستخدام auth_id
      final coachSnapshot = await _supabase
          .from('coaches')
          .select('coach_id')
          .eq('auth_id', authId)
          .maybeSingle();

      if (coachSnapshot == null) {
        // Coach not found, add them to coaches table and get the new coach_id
        final newCoachResponse = await _supabase
            .from('coaches')
            .insert({
              'auth_id': authId,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('coach_id')
            .single();

        final newCoachId = newCoachResponse['coach_id'] as int;
        log('Added new coach with auth_id: $authId and coach_id: $newCoachId');
        return newCoachId;
      } else {
        // Coach found, return the existing coach_id
        final coachId = coachSnapshot['coach_id'] as int;
        log('Found coach with coach_id: $coachId');
        return coachId;
      }
    } catch (e) {
      log('Failed to get or create coach_id: $e');
      return null;
    }
  }

  Future<User> updateProfile(UpdateProfileRequest updateProfileRequest) async {
    // بناء التحديثات بناءً على البيانات اللي موجودة في الـ request
    Map<String, dynamic> user =  getUser().toJson();

    final updates = <String, dynamic>{};
    if (updateProfileRequest.name != null) {
      updates['name'] = updateProfileRequest.name;
      user['name'] = updateProfileRequest.name;
    }
    if (updateProfileRequest.profilePicture != null) {
      updates['profile_picture'] = updateProfileRequest.profilePicture;
      user['profile_picture'] = updateProfileRequest.profilePicture;

    }

    // التحقق إن فيه تحديثات لإجراء العملية
    if (updates.isEmpty) {
      throw Exception('No updates provided for name or profile_picture');
    }

    try {
      final AppPreferences appPref=instance<AppPreferences>();
      // تحديث البيانات في جدول players بناءً على معرّف المستخدم
      await _supabase
          .from('players')
          .update(updates)
          .eq('player_id',appPref.getUserId());

      appPref.setUser(jsonEncode(user));
      // إرجاع بيانات المستخدم الحالي من auth.users
      return _supabase.auth.currentUser!;
    } catch (e) {
      // معالجة الأخطاء (مثلاً لو الـ player مش موجود أو فيه مشكلة في التحديث)
      throw Exception('Failed to update profile: $e');
    }
  }
  // تسجيل الخروج
  Future logout() async {
    await _supabase.auth.signOut();
  }

  // حذف الحساب
  Future deleteAccount() async {
    await _supabase.auth.admin.deleteUser(_supabase.auth.currentUser!.id);
  }

  // جلب المستخدم للـ Dashboard
  User dashboard() {
    return _supabase.auth.currentUser!;
  }

  Future<String?> uploadImageToSupabase(File imageFile, String folderName) async {
    try {
      print(folderName);
      String fileName = imageFile.path.split('/').last;
      final String path = 'public/$fileName'; // You can change this path structure

      await _supabase.storage.from(folderName).upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String downloadUrl =
      _supabase.storage.from(folderName).getPublicUrl(path);

      print('Uploaded image URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

}
