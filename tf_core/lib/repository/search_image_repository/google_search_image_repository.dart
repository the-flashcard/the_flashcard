import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';

class GoogleSearchImageRepository extends SearchImageRepository {
  final String url;
  final String cx;
  final String key;

  GoogleSearchImageRepository({
    @required this.url,
    @required this.cx,
    @required this.key,
  });

  @override
  Future<List<ImageRecord>> search(String query,
      {int from = 0, int count = 10}) async {
    List<ImageRecord> result = [];
    final fullUrl = url +
        "&searchType=image" +
        "&cx=$cx" +
        "&key=$key" +
        "&q=$query" +
        "&start=$from" +
        "&num=$count";
    var response = await get(fullUrl);
    var body = jsonDecode(response.body);

    result.addAll(_parseJsonToImageRecords(body));
    return result;
  }

  List<ImageRecord> _parseJsonToImageRecords(Map<String, dynamic> json) {
    ImageRecord _parseImageRecord(Map<String, dynamic> data) {
      String url = data["link"];
      Map<String, dynamic> image = data["image"];
      String thumbnailUrl = image["thumbnailLink"];

      return ImageRecord(url, thumbnailUrl);
//
//      if (pagemapJson['cse_image'] != null) {
//        Map<String, dynamic> cseImage = pagemapJson['cse_image'].first;
//        Map<String, dynamic> cseThumb = {};
//        if (pagemapJson['cse_thumbnail'] != null) {
//          cseThumb = pagemapJson['cse_thumbnail'].first;
//        }
//        return ImageRecord(cseImage['src'] ?? '', cseThumb['src'] ?? '');
//      } else
//        return ImageRecord('', '');
    }

    List<ImageRecord> data = [];
    json['items']?.forEach((item) {
      data.add(_parseImageRecord(item));
    });

    return data;
  }
}
