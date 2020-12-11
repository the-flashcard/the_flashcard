import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class UploadService {
  Future<String> uploadFromFile(String filePath,
      {void Function(int count, int total) progressCallback});

  Future<String> uploadFromUrl(String url,
      {void Function(int count, int total) progressCallback});
}

class UploadServiceImpl extends UploadService {
  final UploadRepository _uploadRepo;

  UploadServiceImpl(this._uploadRepo);

  @override
  Future<String> uploadFromFile(String filePath,
      {void Function(int count, int total) progressCallback}) {
    return _uploadRepo.uploadFromFile(filePath,
        progressCallback: progressCallback);
  }

  @override
  Future<String> uploadFromUrl(String url,
      {void Function(int count, int total) progressCallback}) {
    return _uploadRepo.uploadFromUrl(url, progressCallback: progressCallback);
  }
}
