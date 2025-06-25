import 'dart:convert';

class ErrorModel {
  final String? errorMessage;
  final String? errorCode;

  ErrorModel({
    this.errorMessage,
    this.errorCode,
  });

  factory ErrorModel.fromRawJson(String str) => ErrorModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
    errorMessage: json["error_message"] ?? json['errorMessage'],
    errorCode: json["error_code"] != null
        ? json['error_code'].toString()
        : (json['errorCode'] != null ? json['errorCode'].toString() : "0"),
  );

  Map<String, dynamic> toJson() => {
    "error_message": errorMessage,
    "error_code": errorCode,
  };
}
