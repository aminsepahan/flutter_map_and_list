import 'package:dio/dio.dart';
import '../../models/network/api_response.dart';
import 'dio_error_handler.dart';

class DioCaller {
  final Dio dio;

  DioCaller({required this.dio});

  DioCaller.test({required this.dio});

  Future<ApiResponse> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      Response response = await dio.get(path, queryParameters: queryParameters, options: options);

      return (response.statusCode! >= 200 || response.statusCode! < 300)
          ? ApiResponse.completed(response.data)
          : ApiResponse.error(DioErrorHandler.handleError(null, response));
    } on DioError catch (e) {
      return ApiResponse.error(DioErrorHandler.handleError(e, e.response!));
    } catch (e) {
      return ApiResponse.error(DioErrorHandler.handleError(null, null));
    }
  }
}
