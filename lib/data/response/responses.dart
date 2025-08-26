// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

@JsonSerializable()
class BaseResponse {
  @JsonKey(name: "status")
  int? status;
  @JsonKey(name: "message")
  String? message;
  @JsonKey(name: "test")
  String? test ;
}

@JsonSerializable()
class UserDataResponse {
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "name")
  String? username;
  @JsonKey(name: "image")
  String? image;
  @JsonKey(name: "age")
  String? age;
  @JsonKey(name: "bodyWeight")
  String? bodyWeight;
  @JsonKey(name: "height")
  String? height;
  @JsonKey(name: "gender")
  String? gender;

  UserDataResponse(
    this.email,
    this.username,
    this.image,
    this.bodyWeight,
    this.height,
    this.age,
    this.gender,
  );

  //form json
  factory UserDataResponse.fromJson(Map<String, dynamic> json) => _$UserDataResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$UserDataResponseToJson(this);
}

@JsonSerializable()
class AuthenticationResponse extends BaseResponse {
  @JsonKey(name: 'data')
  UserDataResponse? userData;
  @JsonKey(name: 'token')
  String? token;

  AuthenticationResponse(
    this.userData,
    this.token,
  );

  //form json
  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$AuthenticationResponseToJson(this);
}

@JsonSerializable()
class LoginAuthenticationResponse extends BaseResponse {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'token')
  String? token;

  LoginAuthenticationResponse(
    this.id,
    this.token,
  );

  //form json
  factory LoginAuthenticationResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginAuthenticationResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$LoginAuthenticationResponseToJson(this);
}

@JsonSerializable()
class SendEmailResponse extends BaseResponse {
  @JsonKey(name: "otp")
  String? otp;

  SendEmailResponse(this.otp);

  //form json
  factory SendEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$SendEmailResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$SendEmailResponseToJson(this);
}

@JsonSerializable()
class RestPasswordResponse extends BaseResponse {
  RestPasswordResponse();

  //form json
  factory RestPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$RestPasswordResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$RestPasswordResponseToJson(this);
}

@JsonSerializable()
class HomeResponse extends BaseResponse {
  @JsonKey(name: 'data')
  DashboardResponse? data;

  HomeResponse(this.data);

  //from json
  factory HomeResponse.fromJson(Map<String, dynamic> json) => _$HomeResponseFromJson(json);

  // to json
  Map<String, dynamic> toJson() => _$HomeResponseToJson(this);
}

@JsonSerializable()
class LiveDoctorResponse {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'username')
  String? username;
  @JsonKey(name: 'image')
  String? image;
  @JsonKey(name: 'isLive')
  bool? isLive;
  @JsonKey(name: 'views')
  int? views;
  @JsonKey(name: 'avgRating')
  String? avgRating;
  @JsonKey(name: 'price')
  int? price;
  @JsonKey(name: 'specialist')
  String? specialist;

  LiveDoctorResponse(
    this.id,
    this.username,
    this.image,
    this.isLive,
    this.views,
    this.avgRating,
    this.price,
    this.specialist,
  );

  factory LiveDoctorResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveDoctorResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$LiveDoctorResponseToJson(this);
}

@JsonSerializable()
class FeatureDoctorsResponse {
  @JsonKey(name: 'doc')
  DoctorDataResponse doctorDataResponse;

  FeatureDoctorsResponse(this.doctorDataResponse);

  factory FeatureDoctorsResponse.fromJson(Map<String, dynamic> json) =>
      _$FeatureDoctorsResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$FeatureDoctorsResponseToJson(this);
}

@JsonSerializable()
class DoctorDataResponse {
  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'username')
  String? username;
  @JsonKey(name: 'image')
  String? image;
  @JsonKey(name: 'isLive')
  bool? isLive;
  @JsonKey(name: 'isLiked')
  bool? isLiked;
  @JsonKey(name: 'views')
  int? views;
  @JsonKey(name: 'avgRating')
  String? avgRating;
  @JsonKey(name: 'price')
  int? price;
  @JsonKey(name: 'specialist')
  String? specialist;

  DoctorDataResponse(
    this.id,
    this.username,
    this.image,
    this.isLiked,
    this.isLive,
    this.views,
    this.avgRating,
    this.price,
    this.specialist,
  );

  factory DoctorDataResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorDataResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$DoctorDataResponseToJson(this);
}

@JsonSerializable()
class DashboardResponse {
  @JsonKey(name: 'userData')
  UserDataResponse? userData;

  DashboardResponse(
    this.userData,
  );

  //from json
  factory DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);

  //to json
  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);
}

// @JsonSerializable()
// class StoresDetailsResponse extends BaseResponse {
//   @JsonKey(name: 'id')
//   int? id;
//   @JsonKey(name: 'image')
//   String? image;
//   @JsonKey(name: 'title')
//   String? title;
//   @JsonKey(name: 'details')
//   String? details;
//   @JsonKey(name: 'services')
//   String? services;
//   @JsonKey(name: 'about')
//   String? about;
//
//   StoresDetailsResponse(
//     this.id,
//     this.image,
//     this.title,
//     this.details,
//     this.services,
//     this.about,
//   );
//
//   //from json
//   factory StoresDetailsResponse.fromJson(Map<String, dynamic> json) =>
//       _$StoresDetailsResponseFromJson(json);
//
//   //to json
//   Map<String, dynamic> toJson() => _$StoresDetailsResponseToJson(this);
// }
