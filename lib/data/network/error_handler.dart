import 'package:tranex_users/data/network/failure.dart';
import 'package:tranex_users/presentation/resources/string_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ErrorHandler implements Exception {
  final Failure failure;

  ErrorHandler.handle(dynamic error) : failure = _handleError(error);

  static Failure _handleError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return DataSource.unAuthorised.getFailure();
        case 'Email not confirmed':
          return DataSource.unAuthorised.getFailure();
        case 'User already registered':
          return DataSource.badRequest.getFailure();
        default:
          return DataSource.customDefault.getFailure(message: error.message);
      }
    } else if (error is PostgrestException) {
      switch (error.code) {
        case '400':
          return DataSource.badRequest.getFailure();
        case '401':
          return DataSource.unAuthorised.getFailure();
        case '403':
          return DataSource.forbidden.getFailure();
        case '404':
          return DataSource.notFound.getFailure();
        case '500':
          return DataSource.internalServerError.getFailure();
        default:
          return DataSource.customDefault.getFailure(message: error.message);
      }
    } else if (error is Exception) {
// Handle general exceptions (e.g., network issues or custom exceptions)
      if (error.toString().contains('Failed host lookup') ||
          error.toString().contains('SocketException')) {
        return DataSource.noInternetConnection.getFailure();
      }
      if (error.toString().contains('User is not a head coach')) {
        return DataSource.customDefault
            .getFailure(message: 'User is not a head coach');
      }
      return DataSource.customDefault.getFailure(message: error.toString());
    } else {
// Any other unexpected error
      return DataSource.customDefault.getFailure(message: error.toString());
    }
  }
}

enum DataSource {
  success,
  noContent,
  badRequest,
  forbidden,
  unAuthorised,
  notFound,
  internalServerError,
  connectTimeout,
  cancel,
  receiveTimeout,
  sendTimeout,
  cacheError,
  noInternetConnection,
  customDefault,
}

extension DataSourceExtension on DataSource {
  Failure getFailure({String? message}) {
    switch (this) {
      case DataSource.success:
        return Failure(
          code: ResponseCode.success,
          message: ResponseMessage.success,
        );
      case DataSource.noContent:
        return Failure(
          code: ResponseCode.noContent,
          message: ResponseMessage.noContent,
        );
      case DataSource.badRequest:
        return Failure(
          code: ResponseCode.badRequest,
          message: message ?? ResponseMessage.badRequest,
        );
      case DataSource.forbidden:
        return Failure(
          code: ResponseCode.forbidden,
          message: message ?? ResponseMessage.forbidden,
        );
      case DataSource.unAuthorised:
        return Failure(
          code: ResponseCode.unAuthorised,
          message: message ?? ResponseMessage.unAuthorised,
        );
      case DataSource.notFound:
        return Failure(
          code: ResponseCode.notFound,
          message: message ?? ResponseMessage.notFound,
        );
      case DataSource.internalServerError:
        return Failure(
          code: ResponseCode.internalServerError,
          message: message ?? ResponseMessage.internalServerError,
        );
      case DataSource.connectTimeout:
        return Failure(
          code: ResponseCode.connectTimeout,
          message: ResponseMessage.connectTimeout,
        );
      case DataSource.cancel:
        return Failure(
          code: ResponseCode.cancel,
          message: ResponseMessage.cancel,
        );
      case DataSource.receiveTimeout:
        return Failure(
          code: ResponseCode.receiveTimeout,
          message: ResponseMessage.receiveTimeout,
        );
      case DataSource.sendTimeout:
        return Failure(
          code: ResponseCode.sendTimeout,
          message: ResponseMessage.sendTimeout,
        );
      case DataSource.cacheError:
        return Failure(
          code: ResponseCode.cacheError,
          message: ResponseMessage.cacheError,
        );
      case DataSource.noInternetConnection:
        return Failure(
          code: ResponseCode.noInternetConnection,
          message: ResponseMessage.noInternetConnection,
        );
      case DataSource.customDefault:
        return Failure(
          code: ResponseCode.customDefault,
          message: message ?? ResponseMessage.customDefault,
        );
    }
  }
}

class ResponseCode {
  static const int success = 200; // success with data
  static const int noContent = 201; // success with no data (no content)
  static const int badRequest = 400; // failure, API rejected request
  static const int unAuthorised = 401; // failure, user is not authorised
  static const int forbidden = 403; // failure, API rejected request
  static const int notFound = 404; // failure, not found
  static const int internalServerError = 500; // failure, crash in server side

// local status code
  static const int connectTimeout = -1;
  static const int cancel = -2;
  static const int receiveTimeout = -3;
  static const int sendTimeout = -4;
  static const int cacheError = -5;
  static const int noInternetConnection = -6;
  static const int customDefault = -7;
}

class ResponseMessage {
  static String success = AppStrings.success; // success with data
  static String noContent =
      AppStrings.noContent; // success with no data (no content)
  static String badRequest =
      AppStrings.badRequestError; // failure, API rejected request
  static String unAuthorised =
      AppStrings.unauthorizedError; // failure, user is not authorised
  static String forbidden =
      AppStrings.forbiddenError; // failure, API rejected request
  static String notFound = AppStrings.notFoundError; // failure, not found
  static String internalServerError =
      AppStrings.internalServerError; // failure, crash in server side
  static String connectTimeout = AppStrings.timeoutError;
  static String cancel = AppStrings.defaultError;
  static String receiveTimeout = AppStrings.timeoutError;
  static String sendTimeout = AppStrings.timeoutError;
  static String cacheError = AppStrings.cacheError;
  static String noInternetConnection = AppStrings.noInternetError;
  static String customDefault = AppStrings.defaultError;
}

class ApiInternalStatus {
  static const int success = 1;
  static const int failure = 0;
}
