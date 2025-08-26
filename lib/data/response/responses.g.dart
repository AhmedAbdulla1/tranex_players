// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse()
  ..status = (json['status'] as num?)?.toInt()
  ..message = json['message'] as String?
  ..test = json['test'] as String?;

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'test': instance.test,
    };

UserDataResponse _$UserDataResponseFromJson(Map<String, dynamic> json) =>
    UserDataResponse(
      json['email'] as String?,
      json['name'] as String?,
      json['image'] as String?,
      json['bodyWeight'] as String?,
      json['height'] as String?,
      json['age'] as String?,
      json['gender'] as String?,
    );

Map<String, dynamic> _$UserDataResponseToJson(UserDataResponse instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.username,
      'image': instance.image,
      'age': instance.age,
      'bodyWeight': instance.bodyWeight,
      'height': instance.height,
      'gender': instance.gender,
    };

AuthenticationResponse _$AuthenticationResponseFromJson(
        Map<String, dynamic> json) =>
    AuthenticationResponse(
      json['data'] == null
          ? null
          : UserDataResponse.fromJson(json['data'] as Map<String, dynamic>),
      json['token'] as String?,
    )
      ..status = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?
      ..test = json['test'] as String?;

Map<String, dynamic> _$AuthenticationResponseToJson(
        AuthenticationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'test': instance.test,
      'data': instance.userData,
      'token': instance.token,
    };

LoginAuthenticationResponse _$LoginAuthenticationResponseFromJson(
        Map<String, dynamic> json) =>
    LoginAuthenticationResponse(
      (json['id'] as num?)?.toInt(),
      json['token'] as String?,
    )
      ..status = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?
      ..test = json['test'] as String?;

Map<String, dynamic> _$LoginAuthenticationResponseToJson(
        LoginAuthenticationResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'test': instance.test,
      'id': instance.id,
      'token': instance.token,
    };

SendEmailResponse _$SendEmailResponseFromJson(Map<String, dynamic> json) =>
    SendEmailResponse(
      json['otp'] as String?,
    )
      ..status = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?
      ..test = json['test'] as String?;

Map<String, dynamic> _$SendEmailResponseToJson(SendEmailResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'test': instance.test,
      'otp': instance.otp,
    };

RestPasswordResponse _$RestPasswordResponseFromJson(
        Map<String, dynamic> json) =>
    RestPasswordResponse()
      ..status = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?
      ..test = json['test'] as String?;

Map<String, dynamic> _$RestPasswordResponseToJson(
        RestPasswordResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'test': instance.test,
    };

HomeResponse _$HomeResponseFromJson(Map<String, dynamic> json) => HomeResponse(
      json['data'] == null
          ? null
          : DashboardResponse.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..status = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?
      ..test = json['test'] as String?;

Map<String, dynamic> _$HomeResponseToJson(HomeResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'test': instance.test,
      'data': instance.data,
    };

LiveDoctorResponse _$LiveDoctorResponseFromJson(Map<String, dynamic> json) =>
    LiveDoctorResponse(
      (json['id'] as num?)?.toInt(),
      json['username'] as String?,
      json['image'] as String?,
      json['isLive'] as bool?,
      (json['views'] as num?)?.toInt(),
      json['avgRating'] as String?,
      (json['price'] as num?)?.toInt(),
      json['specialist'] as String?,
    );

Map<String, dynamic> _$LiveDoctorResponseToJson(LiveDoctorResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'image': instance.image,
      'isLive': instance.isLive,
      'views': instance.views,
      'avgRating': instance.avgRating,
      'price': instance.price,
      'specialist': instance.specialist,
    };

FeatureDoctorsResponse _$FeatureDoctorsResponseFromJson(
        Map<String, dynamic> json) =>
    FeatureDoctorsResponse(
      DoctorDataResponse.fromJson(json['doc'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeatureDoctorsResponseToJson(
        FeatureDoctorsResponse instance) =>
    <String, dynamic>{
      'doc': instance.doctorDataResponse,
    };

DoctorDataResponse _$DoctorDataResponseFromJson(Map<String, dynamic> json) =>
    DoctorDataResponse(
      (json['id'] as num?)?.toInt(),
      json['username'] as String?,
      json['image'] as String?,
      json['isLiked'] as bool?,
      json['isLive'] as bool?,
      (json['views'] as num?)?.toInt(),
      json['avgRating'] as String?,
      (json['price'] as num?)?.toInt(),
      json['specialist'] as String?,
    );

Map<String, dynamic> _$DoctorDataResponseToJson(DoctorDataResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'image': instance.image,
      'isLive': instance.isLive,
      'isLiked': instance.isLiked,
      'views': instance.views,
      'avgRating': instance.avgRating,
      'price': instance.price,
      'specialist': instance.specialist,
    };

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      json['userData'] == null
          ? null
          : UserDataResponse.fromJson(json['userData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'userData': instance.userData,
    };
