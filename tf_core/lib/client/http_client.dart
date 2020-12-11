import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tf_core/tf_core.dart';

abstract class BaseClient {
  Future<dynamic> get(
    String path, {
    Map<String, dynamic> params,
    Options options,
  });
  Future<dynamic> post(
    String path,
    dynamic body, {
    Map<String, dynamic> params,
    ProgressCallback onSendProgress,
    Options options,
  });
  Future<dynamic> put(String path, dynamic body, {Options options});
  Future<dynamic> delete(String path, {Options options});
}

class HttpClient extends BaseClient {
  final Dio dio;

  HttpClient(this.dio);

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic> params, Options options}) {
    return dio
        .get(path,
            queryParameters: params ?? <String, dynamic>{},
            options: options == null
                ? Options(responseType: ResponseType.plain)
                : options)
        .then((response) => _handleResult(response))
        .catchError((e) => _handleError(path, e));
  }

  @override
  Future<dynamic> post(String path, body,
      {Map<String, dynamic> params, onSendProgress, Options options}) {
    return dio
        .post(path,
            queryParameters: params ?? <String, dynamic>{},
            data: body,
            onSendProgress: onSendProgress,
            options: options == null
                ? Options(responseType: ResponseType.plain)
                : options)
        .then((response) {
      return _handleResult(response);
    }).catchError((e, stackTrace) {
      _handleError(path, e);
      print(stackTrace);
    });
  }

  @override
  Future<dynamic> put(String path, body, {Options options}) {
    return dio
        .put(path,
            data: body,
            options: options ?? Options(responseType: ResponseType.plain))
        .then((response) => _handleResult(response))
        .catchError((e) => _handleError(path, e));
  }

  @override
  Future<dynamic> delete(String path, {Options options}) {
    return dio
        .delete(path,
            options: options ?? Options(responseType: ResponseType.plain))
        .then((response) => _handleResult(response))
        .catchError((e) => _handleError(path, e));
  }
}

dynamic _handleResult(Response response) {
  try {
    Map<String, dynamic> json = jsonDecode(response.data);
    if (!json['success']) {
      if (json['error'] != null)
        throw APIException.fromJson(json['error']);
      else
        throw Exception(); //don't have json
    }
    return json['data'];
  } on APIException catch (e) {
    throw e;
  } catch (e) {
    throw APIException.from(e);
  }
}

void _handleError(String path, dynamic error) {
  try {
    if (error is APIException) {
      throw error;
    }
    bool isDioError = error is DioError &&
        error.response != null &&
        error.response.data != null;
    if (isDioError) {
      Map<String, dynamic> json = jsonDecode(error.response.data);
      throw APIException.fromJson(json['error']);
    }
    throw APIException.from(error);
  } on APIException catch (ex) {
    throw ex;
  } catch (ex) {
    throw APIException.from(ex);
  }
}
