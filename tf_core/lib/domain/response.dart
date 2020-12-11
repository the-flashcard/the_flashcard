import 'package:tf_core/tf_core.dart';

abstract class Response<T> {
  Response(this.success, this.data, this.error);

  bool success;
  T data;
  APIException error;

  bool isSuccess() {
    return success;
  }

  APIException getError() {
    return error;
  }

  T getData() {
    return data;
  }

  @override
  String toString() {
    return "{ \"Success\": $success, data: $data, error: $error }";
  }
}
