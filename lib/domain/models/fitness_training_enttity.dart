import 'package:tranex_users/domain/models/training_entity.dart'
    show TrainingDetails;

class FitnessTrainingDetails extends TrainingDetails {
  final double w;
  final List<double> conForce;
  final List<double> eccForce;
  final double avgConSpeed;
  final double avgEccSpeed;
  final double maxConSpeed;
  final double maxEccSpeed;

  FitnessTrainingDetails({
    required this.w,
    required this.conForce,
    required this.eccForce,
    required this.avgConSpeed,
    required this.avgEccSpeed,
    required this.maxConSpeed,
    required this.maxEccSpeed,
  });

  factory FitnessTrainingDetails.fromJson(Map<String, dynamic> json) {
    return FitnessTrainingDetails(
      w: (json['W'] as num).toDouble(),
      conForce: (json['CF'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      eccForce: (json['EF'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      avgConSpeed: (json['ACS'] as num).toDouble(),
      avgEccSpeed: (json['AES'] as num).toDouble(),
      maxConSpeed: (json['MCS'] as num).toDouble(),
      maxEccSpeed: (json['MES'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'W': w,
        'CF': conForce,
        'EF': eccForce,
        'ACS': avgConSpeed,
        'AES': avgEccSpeed,
        'MCS': maxConSpeed,
        'MES': maxEccSpeed,
      };
}
