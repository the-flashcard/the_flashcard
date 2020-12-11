import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tf_core/tf_core.dart';

class APIException implements Exception {
  final String reason;
  final String message;

  const APIException(this.reason, this.message);

  static APIException from(dynamic error) {
    try {
      if (error is DioError &&
          error.response != null &&
          error.response.data != null) {
        Map<String, dynamic> json = jsonDecode(error.response.data);
        return APIException.fromJson(json['error']);
      }
    } catch (_) {}
    var entry = _buildReason(error);
    return APIException(entry.key, entry.value);
  }

  APIException.fromJson(Map<String, dynamic> json)
      : reason = json['reason'],
        message = json['message'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['reason'] = this.reason;
    data['message'] = this.message;
    return data;
  }

  @override
  String toString() {
    return '$runtimeType - Reason: $reason, Message: $message';
  }

  static MapEntry<String, String> _buildReason(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.CONNECT_TIMEOUT:
        case DioErrorType.SEND_TIMEOUT:
        case DioErrorType.RECEIVE_TIMEOUT:
          return MapEntry(
              ApiErrorReasons.ConnectionTimeOutError, "Connection Timeout");
        case DioErrorType.CANCEL:
          return MapEntry(
              ApiErrorReasons.CancelledConnectionError, "Connection Cancelled");
        case DioErrorType.DEFAULT:
          if (error.error is SocketException)
            return MapEntry(ApiErrorReasons.NoConnectionError, "No Connection");
          else
            return MapEntry(ApiErrorReasons.ClientError, error.message);
          break;
        default:
          return MapEntry(ApiErrorReasons.ClientError, error.message);
      }
    } else {
      return MapEntry(ApiErrorReasons.ClientError, error.toString());
    }
  }
}
