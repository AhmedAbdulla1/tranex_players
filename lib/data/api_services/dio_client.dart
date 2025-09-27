import 'package:dio/dio.dart';
import 'package:tranex_users/data/network/api.dart';

Dio createDioClient() {
  final dio = Dio();

  dio.options.headers = {
    'apikey': ApiUrl.supabaseAnonKey,
    'Authorization': 'Bearer ${ApiUrl.supabaseAnonKey}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  return dio;
}
