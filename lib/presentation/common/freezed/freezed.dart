import 'package:firesport_users/app/constant.dart';
import 'package:firesport_users/domain/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed.freezed.dart';

@freezed
class SignupObject with _$SignupObject {
  factory SignupObject(
    String name,
    String email,
    String password,
    String boydWeight,
    String height,
    String age,
    String gender,
  ) = _SignupObject;
}

@freezed
class LoginObject with _$LoginObject {
  factory LoginObject(
    String email,
    String password,
  ) = _LoginObject;
}

@freezed
class ForgotPasswordObject with _$ForgotPasswordObject {
  factory ForgotPasswordObject(
    String email,
    String otp,
    String password,
  ) = _ForgotPasswordObject;
}

@freezed
class TrainingObject with _$TrainingObject {
  factory TrainingObject(
    String exercises,
    String image,
    DeviceData? deviceType,
    double weight,
    bool autoStart,
    int idleTime,
  ) = _TrainingObject;
}

@freezed
class AddDeviceObject with _$AddDeviceObject {
  factory AddDeviceObject({
   required String deviceName,
   required  String ssid,
   required String password,
  }) =_AddDeviceObject;
}
@freezed
class AddNewExerciseObject with _$AddNewExerciseObject {
  factory AddNewExerciseObject({
    required String exerciseName,
    required  int categoryId,
    required  String categoryName,
    required DeviceData? deviceType,
    required String imageUrl,
  }) =_AddNewExerciseObject;
}