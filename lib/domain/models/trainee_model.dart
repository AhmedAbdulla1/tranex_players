
import 'package:hive/hive.dart';
part 'trainee_model.g.dart';

@HiveType(typeId: 0)
class TraineeData {
  @HiveField(0)
  String traineeName;
  @HiveField(1)
  String? country;

  @HiveField(3)
  String? weaponType;

  @HiveField(4)
  int? age;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  String photo;

  @HiveField(7)
  String traineeId;

  @HiveField(8)
  bool isFencer;

  @HiveField(9)
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
      traineeName: json['name'] ?? '',
      traineeId: json['athlete_id'],
      isFencer: json['is_fencer'],
      photo: json['profile_picture'] ?? '',
      isActive: json['is_active'] ?? false,
      country: json['country'] ?? 'EG',
      weaponType: json['weapon_type'] ?? '',
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