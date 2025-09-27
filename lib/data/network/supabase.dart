import 'dart:developer';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/app/app_prefs.dart';
import 'package:tranex_users/app/constant.dart';
import 'package:tranex_users/app/di.dart';
import 'package:tranex_users/data/network/requests.dart';

class SupabaseAppClient {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> loginWithEmail(LoginRequest loginRequest) async {
    final response = await _supabase.auth.signInWithPassword(
      email: loginRequest.email,
      password: loginRequest.password,
    );
    log(response.toString(), name: 'loginResponse');
    // Verify the user is a coach
    final userId = response.user?.id;
    late Map<String, dynamic> traineeData;
    if (userId != null) {
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .eq('role', 'athlete')
          .maybeSingle();
      if (userData == null) {
        await _supabase.auth.signOut(); // Sign out if not head_coach
        return throw Exception('User is not a athlete');
      }
      traineeData = await _supabase.rpc<Map<String, dynamic>>(
          'get_user_profile',
          params: {'p_user_id': userId});
    }
    return traineeData;
  }

  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    final response = await _supabase.auth.signUp(
      email: registerRequest.email,
      password: registerRequest.password,
      // Todo : sport id
      data: {
        'full_name': registerRequest.name,
        'sport_id': "59e3644d-b113-4bdb-86da-1b892bd9679e",
        'role': 'coach',
      },
    );
    log(response.toString(), name: 'registerResponse');
    return response;
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
      const webClientId =
          '291040378627-p48pvj5im5p480barti2m5riosk93qej.apps.googleusercontent.com';
      const iosClientId =
          '291040378627-u4mrciumuf87ojcg067oq6pbn7ciib9r.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      log('GoogleSignIn initialized: ${googleSignIn.clientId}');

      // Check if user is already signed in
      final isSignedIn = await googleSignIn.isSignedIn();
      log('Is signed in: $isSignedIn');

      // Attempt sign-in
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        log('Google Sign-In cancelled by user');
        return null;
      }
      log('Google User: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      log('Access Token: $accessToken');

      final idToken = googleAuth.idToken;
      log('ID Token: $idToken');

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
      log('Supabase response: ${response.toString()}');

      if (response.user != null) {
        print('تم تسجيل الدخول بنجاح: ${response.user!.email}');
        return response.user!;
      } else {
        print('فشل في تسجيل الدخول في Supabase');
        return null;
      }
    } catch (error, stackTrace) {
      print('خطأ أثناء تسجيل الدخول: $error');
      print('Stack trace: $stackTrace');
      return null;
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
  User? getUser() {
    String? displayName =
        _supabase.auth.currentUser?.userMetadata?['display_name'] as String?;
    print('Current User Display Name: $displayName');
    return _supabase.auth.currentUser;
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
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("❌ No authenticated user found");
      }

      log("👤 Updating profile for user: $userId");

      final tableUpdates = <String, dynamic>{};

      if (updateProfileRequest.profilePicture != null) {
        tableUpdates['profile_image'] = updateProfileRequest.profilePicture;
        log("🖼️ Profile image to update: ${updateProfileRequest.profilePicture}");
      }

      if (updateProfileRequest.name != null) {
        tableUpdates['full_name'] = updateProfileRequest.name;
        log("✏️ Full name to update: ${updateProfileRequest.name}");
      }

      if (tableUpdates.isNotEmpty) {
        final response = await _supabase
            .from('users')
            .update(tableUpdates)
            .eq('id', userId)
            .select()
            .single();

        log("✅ Profile updated in users table: $response");
      } else {
        log("⚠️ No updates provided, skipping DB update.");
      }

      return _supabase.auth.currentUser!;
    } catch (e, st) {
      log("❌ Error while updating profile: $e", stackTrace: st);
      rethrow;
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

  Future<String?> uploadImageToSupabase(
      File imageFile, String folderName) async {
    try {
      print(folderName);
      String fileName = imageFile.path.split('/').last;
      final String path =
          'public/$fileName'; // You can change this path structure

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

  Future<bool> connectToHeadCoach({required String code}) async {
    try {
      String uid = _appPreferences.getUid();
      log("Code: $code");
      log("Uid : $uid");
      final response = await _supabase
          .rpc('join_head_coach', params: {'coach_id': uid, 'code': code});

      log(response.toString(), name: 'connect_to_head_coach in supabase');
      return response;
    } catch (e) {
      log('Error connecting to head coach: $e');
      return false;
    }
  }
}
