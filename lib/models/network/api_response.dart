import '../../utils/network/api_error.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  ApiError? apiError;

  ApiResponse.completed(this.data) : status = Status.COMPLETED;

  ApiResponse.error(this.apiError) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n ApiError : $apiError \n Data : $data";
  }
}

enum Status { COMPLETED, ERROR }
