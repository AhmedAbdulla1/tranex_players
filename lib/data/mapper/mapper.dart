import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tranex_users/app/constant.dart';
import 'package:tranex_users/app/extensions.dart';
import 'package:tranex_users/data/response/responses.dart';
import 'package:tranex_users/domain/models/models.dart';

extension UserDataResponseMapper on UserDataResponse? {
  UserData toDomain() {
    return UserData(
      email: this?.email.orEmpty() ?? Constant.empty,
      username: this?.username.orEmpty() ?? Constant.empty,
      image: this?.image ?? Constant.image,
    );
  }
}

extension UserExtension on User? {
  UserData toDomain() {
    return UserData(
      email: this?.email.orEmpty() ?? Constant.empty,
      username: Constant.empty,
      image: this?.userMetadata!['image'] ?? "",
    );
  }
}

extension AuthenticationResponseMapper on AuthenticationResponse? {
  Authentication toDomain() {
    return Authentication(
        userData: this?.userData.toDomain(),
        token: this?.token.orEmpty() ?? Constant.empty);
  }
}

extension LoginAuthenticationMapper on LoginAuthenticationResponse? {
  LoginAuthentication toDomain() {
    return LoginAuthentication(
      id: this?.id.orZero() ?? Constant.zero,
      token: this?.token.orEmpty() ?? Constant.empty,
    );
  }
}

extension SendEmailResponsMapper on SendEmailResponse? {
  SendEmail toDomain() {
    return SendEmail(
      otp: this?.otp.orEmpty() ?? Constant.empty,
      message: this?.message.orEmpty() ?? Constant.empty,
    );
  }
}

extension RestPasswordResponsMapper on RestPasswordResponse? {
  String toDomain() {
    return this?.message.orEmpty() ?? Constant.empty;
  }
}

extension TeamsMapper on List<Map<String, dynamic>> {
  List<TraineeData> toDomain({bool withTrainees = true}) {
    List<TraineeData> trainees = [];
    for (Map<String, dynamic> trainee in this) {
      TraineeData traineeData = trainee.traineeDataToDomain();
      trainees.add(traineeData);
    }
    return trainees;
  }

  List<CategoryData> categoriesToDomain() {
    List<CategoryData> categoriesData = [];
    for (Map<String, dynamic> categoryData in this) {
      List<Map<String, dynamic>> exercises =
          (categoryData['exercises'] as List<dynamic>)
              .cast<Map<String, dynamic>>();

      CategoryData data = CategoryData(
          categoryName: categoryData['name'],
          categoryId: categoryData['category_id'],
          exercises: exercises.exercisesToDomain());
      categoriesData.add(data);
    }
    return categoriesData;
  }

  List<ExerciseData> exercisesToDomain() => map((e) {
        return ExerciseData(
            exerciseName: e['name'],
            exerciseId: e['exercise_id'],
            exerciseImage: e['image_url'] ?? '',
            deviceId: e["device_id"]);
      }).toList();

  List<DeviceData> devicesToDomain() => map((e) => DeviceData(
        deviceId: e['device_id'],
        // تغيير من deviceId لـ device_id
        deviceName: e['name'],
        // تغيير من deviceName لـ name
        accessories: (e['accessories'] as List<dynamic>) // Accessories كـ List
            .map((acc) => AccessoryData.fromJson(acc as Map<String, dynamic>))
            .toList(),
      )).toList();

  List<AccessoryData> accessoriesToDomain() => map((e) => AccessoryData(
        accessoryName: e['accessory_name'],
        // تغيير من displayName لـ accessory_name
        min: e['min'],
        max: e['max'],
        interval: e['interval'],
        weight: e['weight'],
      )).toList();
}

extension TrainingDataExtension on Map<String, dynamic> {
  Data dataToDomain() {
    // try {
    Map<String, dynamic> data = this['training_details'] ?? {};
    // تحقق من أن EF و CF هما قوائم
    if (data['EF'] != null && data['EF'] is! List) {
      throw FormatException('EF is not a list: ${data['EF']}');
    }
    if (data['CF'] != null && data['CF'] is! List) {
      throw FormatException('CF is not a list: ${data['CF']}');
    }
    List<dynamic> eFList = data['EF'] ?? [];
    List<double> eccForce = eFList.map<double>((entry) {
      if (entry is double) {
        return entry;
      } else {
        return entry.toDouble();
      }
    }).toList();
    List<dynamic> cFList = data['CF'] ?? [];
    List<double> conForce = cFList.map<double>((entry) {
      if (entry is double)
        return entry;
      else
        return entry.toDouble();
    }).toList();

    // تحويل القيم الأخرى مع التحقق من null
    double weight = double.tryParse(data['W']?.toString() ?? '0.0') ?? 0.0;
    double maxEccSpeed =
        double.tryParse(data['MES']?.toString() ?? '0.0') ?? 0.0;
    double maxConSpeed =
        double.tryParse(data['MCS']?.toString() ?? '0.0') ?? 0.0;
    double avgEccSpeed =
        double.tryParse(data['AES']?.toString() ?? '0.0') ?? 0.0;
    double avgConSpeed =
        double.tryParse(data['ACS']?.toString() ?? '0.0') ?? 0.0;
    int timeBySeconds =
        int.tryParse(this['timeBySeconds']?.toString() ?? '0') ?? 0;

    return Data(
      date: this['created_at'] != null
          ? DateTime.parse(this['created_at'])
          : DateTime.now(),
      eccForce: eccForce.toList() as List<double>,
      conForce: conForce as List<double>,
      maxEccSpeed: maxEccSpeed,
      maxConSpeed: maxConSpeed,
      avgConSpeed: avgConSpeed,
      avgEccSpeed: avgEccSpeed,
      weight: weight,
      timeBySeconds: timeBySeconds,
    );
    // } catch (e, stackTrace) {
    //   // تسجيل الخطأ في وحدة التحكم
    //   print('Error converting data to domain: $e');
    //
    //   // رمي الخطأ للسماح للطبقات العليا بمعالجته
    //   rethrow;
    // }
  }

  TrainingData trainingDataToDomain() {
    print('trainingDataToDomain');
    List<Map<String, dynamic>> data = this['data'] ?? [];
    int numOfSets = 0;
    int overAllTime = 0;
    List<Data> trainingData = data.map((e) {
      Data d = e.dataToDomain();
      overAllTime += d.timeBySeconds;
      return d;
    }).toList();
    return TrainingData(
      trainingId: this['exerciseId'] ?? '',
      overAllReps: trainingData.length,
      overAllSets: numOfSets,
      overAllTime: overAllTime,
      score: 0.0,
      data: trainingData,
    );
  }

  TraineeData traineeDataToDomain() {
    return TraineeData(
        traineeName: this['full_name'],
        photo: this['profile_image'] ?? '',
        traineeId: this['athlete_id'],
        isFencer: this['is_fencer'] ?? false,
        isActive: this['is_active'] ?? false,
        country: this['country'] ?? '',
        weaponType: this['weapon_type'] ?? '',
        age: this['age'],
        exercise: {});
  }
}
