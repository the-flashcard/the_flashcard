import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart';
import 'package:tf_core/tf_core.dart';

abstract class UploadRepository {
  Future<String> uploadFromFile(String filePath,
      {dio.ProgressCallback progressCallback});

  Future<String> uploadFromUrl(String url,
      {dio.ProgressCallback progressCallback});
}

class UploadRepositoryImpl extends UploadRepository {
  final HttpClient _client;

  UploadRepositoryImpl(this._client);

  @override
  Future<String> uploadFromFile(String filePath,
      {dio.ProgressCallback progressCallback}) async {
    final file =
        dio.MultipartFile.fromFileSync(filePath, filename: basename(filePath));
    Log.info("File: $file");
    dio.FormData formData = dio.FormData.fromMap({"file": file});
    var path = await _client.post(
      "/upload",
      formData,
      onSendProgress: progressCallback,
    );

    return path.toString();
  }

  @override
  Future<String> uploadFromUrl(String url,
      {dio.ProgressCallback progressCallback}) async {
    dio.FormData formData = dio.FormData.fromMap({"file": url});
    var path = await _client.post("/upload_from_url", formData,
        onSendProgress: progressCallback);

    return path.toString();
  }
}
