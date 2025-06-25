class ApiError {
  final String message;
  final String? code;

  const ApiError(this.message,{this.code});

  @override
  String toString() {
    return "message: $message";
  }
}

class InternetError extends ApiError {
  InternetError(String message) : super(message);
}

class ServerError extends ApiError {
  ServerError(String message,String code) : super(message,code: code);
}

class UncaughtError extends ApiError {
  UncaughtError(String message) : super(message);
}
