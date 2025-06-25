import 'dart:io';

import 'package:road_surfer_task/utils/network/api_error.dart';
import 'package:dio/dio.dart';

import '../../configs/strings.dart';
import '../../models/network/error_model.dart';

class DioErrorHandler {
  static ApiError handleError(DioError? dioError, Response? response) {
    if (((dioError!.error! is SocketException))) {
      return InternetError(Strings.internetError);
    }

    try {
      final errorModel = ErrorModel.fromJson(response!.data!);
      return ServerError(errorModel.errorMessage!, errorModel.errorCode!);

    } catch (e) {
      return UncaughtError(Strings.serverError);
    }
  }
}
