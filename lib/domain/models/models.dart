class SliderObject {
  String title;
  String subTitle;
  String image;

  SliderObject(this.title, this.subTitle, this.image);
}

class UserData {
  String username;
  String email;
  String image;

  UserData({
    required this.email,
    required this.username,
    required this.image,
    // required this.age,
    // required this.bodyWeight,
    // required this.height,
    // required this.gender,
  });
}

class Authentication {
  UserData? userData;
  String token;

  Authentication({
    required this.userData,
    required this.token,
  });
}

class LoginAuthentication {
  int id;
  String token;

  LoginAuthentication({
    required this.id,
    required this.token,
  });
}

// restPassword
class SendEmail {
  String otp;
  String message;

  SendEmail({
    required this.otp,
    required this.message,
  });
}

// home model
class Home {
  UserData? userData;

  // List<DoctorData>? liveDoctors;
  // List<DoctorData>? popularDoctors;
  // List<FeatureDoctor>? featureDoctors;

  Home({
    required this.userData,
    // required this.liveDoctors,
    // required this.popularDoctors,
    // required this.featureDoctors,
  });
}

class TeamData {
  String teamName;
  String teamId;
  List<TraineeData> trainees;

  TeamData(
      {required this.teamName, required this.trainees, required this.teamId});
}

class TraineeData {
  String traineeName;
  String? country;
  String? weaponType;
  int? age;
  bool isActive;
  String photo;
  String traineeId;
  bool isFencer;
  Map<String, dynamic>? exercise;

  TraineeData(
      {required this.traineeName,
      required this.traineeId,
      this.country,
        this.age,
      required this.isActive,
      this.weaponType,
      required this.isFencer,
      required this.photo,
      this.exercise});

  factory TraineeData.fromJson(Map<String, dynamic> json) {
    return TraineeData(
      traineeName: json['name']??'',
      traineeId: json['athlete_id'],
      isFencer: json['is_fencer'],
      photo: json['profile_picture']??'',
      isActive: json['is_active']??false,
      country: json['country']??'EG',
      weaponType: json['weapon_type']??'',
    );
  }

  Map<String, dynamic> toJson() => {
    'N': traineeName,
    'ID': traineeId,
    'F': isFencer,
    'P': photo,
    'A': isActive,
    'C': country,
    'W': weaponType,
    'AG': age,
    'E': exercise,
  };
}

class TrainingData {
  String trainingId;
  int overAllSets;
  int overAllReps;
  int overAllTime;
  double score;
  List<Data> data;

  TrainingData(
      {required this.trainingId,
      required this.overAllSets,
      required this.overAllReps,
      required this.overAllTime,
      required this.score,
      required this.data});
}

class Data {
  DateTime date;
  List<double> eccForce;
  List<double> conForce;
  double weight;
  double avgEccSpeed;
  double maxEccSpeed;
  double avgConSpeed;
  double maxConSpeed;
  int timeBySeconds;

  Data({
    required this.date,
    required this.eccForce,
    required this.conForce,
    required this.weight,
    required this.avgEccSpeed,
    required this.maxEccSpeed,
    required this.avgConSpeed,
    required this.maxConSpeed,
    required this.timeBySeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'eccForce': eccForce,
      'conForce': conForce,
      'timeBySeconds': timeBySeconds
    };
  }
}

class CategoryData {
  String categoryName;
  int categoryId;
  List<ExerciseData> exercises;

  CategoryData(
      {required this.categoryName,
      required this.categoryId,
      required this.exercises});
}

class ExerciseData {
  String exerciseName;
  int exerciseId;
  String exerciseImage;
  int deviceId;

  ExerciseData({
    required this.exerciseName,
    required this.exerciseId,
    required this.exerciseImage,
    required this.deviceId,
  });

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    return ExerciseData(
      exerciseName: json['exerciseName'],
      exerciseId: json['exerciseId'],
      exerciseImage: json['exerciseImage'],
      deviceId: json['deviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'exerciseId': exerciseId,
      'exerciseImage': exerciseImage,
      'deviceId': deviceId,
    };
  }
}

class DeviceData {
  String deviceName;
  int deviceId;
  List<AccessoryData> accessories;

  DeviceData({
    required this.deviceName,
    required this.deviceId,
    required this.accessories,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      deviceName: json['deviceName'],
      deviceId: json['deviceId'],
      accessories: (json['accessories'] as List)
          .map((item) => AccessoryData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'deviceId': deviceId,
      'accessories':
          accessories.map((accessory) => accessory.toJson()).toList(),
    };
  }
}

class AccessoryData {
  String accessoryName;
  num min;
  num max;
  num interval;
  num weight;

  AccessoryData({
    required this.accessoryName,
    required this.min,
    required this.max,
    required this.interval,
    required this.weight,
  });

  factory AccessoryData.fromJson(Map<String, dynamic> json) {
    return AccessoryData(
      accessoryName: json['accessory_name'],
      min: json['min'],
      max: json['max'],
      interval: json['interval'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessory_name': accessoryName,
      'min': min,
      'max': max,
      'interval': interval,
      'weight': weight,
    };
  }
}
