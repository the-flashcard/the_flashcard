import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tf_core/tf_core.dart' show Config;

class UrlUtils {
  static String resolveUploadUrl(String url) {
    if (url == null || url.isEmpty) return url;
    if (url.startsWith("http")) {
      return url.trim();
    } else {
      return Config.getProtocol() +
          url
              .replaceAll(RegExp("^(/+)"), "")
              .replaceAll(RegExp("^(\\./)+"), "");
    }
  }

  static bool isFormatHtml(String url) {
    return url.contains(RegExp("^https?://"));
  }

  static bool isFormatImage(String url) {
    return url.contains(RegExp('^https?://')) &&
        url.contains(RegExp('.(jpg|gif|png|jpeg)\$'));
  }

  static final _random = Random();

  static String getFileName() {
    String ran = '';
    for (int i = 0; i < 5; ++i) {
      ran += _random.nextInt(100).toString();
    }
    return ran;
  }

  static String randomId({int numberCharacter = 25}) {
    StringBuffer str = StringBuffer();
    _writeId(str, numberCharacter ?? 25);
    return str.toString();
  }

  static void _writeId(StringBuffer str, int numberCharacter) {
    const String chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
    for (int i = 0; i < numberCharacter; ++i) {
      final String char = chars[_random.nextInt(chars.length)];
      str.write(char);
    }
  }

  static var httpClient = HttpClient();

  static Future<File> downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}
