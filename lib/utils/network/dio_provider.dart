import 'package:dio/dio.dart';
import '../../configs/const.dart';

class DioProvider {
  Dio provideDio() {
    Dio dio = Dio(BaseOptions(
        connectTimeout: Const.networkTimeout,
        receiveTimeout: Const.networkTimeout,
        sendTimeout: Const.networkTimeout,
        responseType: ResponseType.json,
        baseUrl: 'https://62ed0389a785760e67622eb2.mockapi.io/spots/v1',
    ));

    return dio;
  }

}
