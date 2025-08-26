// import 'dart:io';
//
// import 'package:firesport_users/app/app_prefs.dart';
// import 'package:firesport_users/app/constant.dart';
// import 'package:firesport_users/app/di.dart';
// import 'package:firesport_users/data/network/requests.dart';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//
// class AppServicesClient {
//   final AppPreferences _appPreferences = instance<AppPreferences>();
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   // final FirebaseAuth auth = FirebaseAuth.instance;
//
//   // final FirebaseFirestore fireStore = FirebaseFirestore.instance;
//
//   Future<User> loginWithEmail(LoginRequest loginRequest) async {
//     await auth.signInWithEmailAndPassword(
//       email: loginRequest.email,
//       password: loginRequest.password,
//     );
//     _appPreferences.setLoginMethod(LoginMethod.email);
//     return auth.currentUser!;
//   }
//
//   Future<User> register(RegisterRequest registerRequest) async {
//     UserCredential result = await auth.createUserWithEmailAndPassword(
//       email: registerRequest.email,
//       password: registerRequest.password,
//     );
//     await auth.currentUser!.updateDisplayName(registerRequest.name);
//     return result.user!;
//   }
//
//   Future<User> loginWithGoogle() async {
//     final googleUser = await _googleSignIn.signIn();
//     final googleAuth = await googleUser?.authentication;
//
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth?.accessToken,
//       idToken: googleAuth?.idToken,
//     );
//
//     final userCredential = await auth.signInWithCredential(credential);
//     _appPreferences.setLoginMethod(LoginMethod.google);
//     return userCredential.user!;
//   }
//
//   Future<User> loginWithApple() async {
//     final appleCredential = await SignInWithApple.getAppleIDCredential(
//       scopes: [
//         AppleIDAuthorizationScopes.email,
//         AppleIDAuthorizationScopes.fullName,
//       ],
//     );
//
//     final oauthCredential = OAuthProvider("apple.com").credential(
//       idToken: appleCredential.identityToken,
//       accessToken: appleCredential.authorizationCode,
//     );
//     final userCredential = await auth.signInWithCredential(oauthCredential);
//     return  userCredential.user!;
//   }
//
//   Future<User> registerAnonymous() async {
//     UserCredential result = await auth.signInAnonymously();
//     _appPreferences.setLoginMethod(LoginMethod.anonymous);
//     return result.user!;
//   }
//
//   User? getUser() {
//     return auth.currentUser;
//   }
//
//   Future<User> updateProfile(UpdateProfileRequest updateProfileRequest) async {
//     if (updateProfileRequest.profilePicture != null) {
//       await auth.currentUser!
//           .updatePhotoURL(updateProfileRequest.profilePicture);
//     }
//     if (updateProfileRequest.name != null) {
//       await auth.currentUser!.updateDisplayName(updateProfileRequest.name);
//     }
//     auth.currentUser!.reload();
//     return auth.currentUser!;
//   }
//
//   Future logout() async {
//     if (_appPreferences.getLoginMethod() == LoginMethod.google.name) {
//       await _googleSignIn.signOut();
//     }
//     await auth.signOut();
//   }
//
//   Future deleteAccount() async {
//     User? user = auth.currentUser;
//     await user!.delete();
//   }
//
//   User dashboard() {
//     return auth.currentUser!;
//   }
//
//   Future<String?> uploadImageToFirebase(File imageFile,String folderName) async {
//     try {
//       // Get the file path from the imageFile object
//       String filePath = imageFile.path;
//
//       // Split the file path by the '/' separator to get the file name
//       List<String> pathSegments = filePath.split('/');
//
//       // Get the last segment which is the file name
//       String imageName = pathSegments.last;
//
//       // Create a reference to the Firebase Storage location
//       Reference storageReference =
//           FirebaseStorage.instance.ref().child("$folderName/$imageName");
//
//       // Upload the file to Firebase Storage
//       UploadTask uploadTask = storageReference.putFile(imageFile);
//
//       // Get the download URL
//       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
//       String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//
//       // Return the download URL
//       return downloadUrl;
//     } catch (e) {
//       return null;
//     }
//   }
// }
