import 'generate_info.dart';

class GenerateWordInfo {
  String word;
  GenerateInfo data;

  GenerateWordInfo({this.word, this.data});

  GenerateWordInfo.def(this.word) {
    var json = {
      "card_version": 100,
      "fronts": [
        {
          "components": [
            {"text": word, "component_type": "text"}
          ],
          "is_horizontal": false,
          "component_type": "panel"
        }
      ]
    };
    data = GenerateInfo.fromJson(json);
  }

  GenerateWordInfo.fromJson(Map<String, dynamic> json) {
    if (json['word'] != null) this.word = json['word'];
    if (json['data'] != null) {
      data = GenerateInfo.fromJson(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    if (this.word != null) data['word'] = this.word;
    if (this.data != null) data['data'] = this.data.toJson();
    return data;
  }
}

class GenerateData {
  String word;
  final Map<String, GenerateInfo> data = {};

  GenerateData.fromJson(Map<String, dynamic> json) {
    if (json['word'] != null) this.word = json['word'];
    if (json['data'] != null) {
      json['data'].forEach((k, v) {
        data[k] = GenerateInfo.fromJson(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.word != null) data['word'] = this.word;
    if (this.data != null)
      data['data'] = this.data.map((k, v) => MapEntry(k, v.toJson()));
    return data;
  }

  GenerateWordInfo asGenerateWordInfo() {
    var nounData = data["noun"];
    var verbData = data["verb"];
    var adjData = data["adjective"];

    if (nounData != null)
      return GenerateWordInfo(word: word, data: nounData);
    else if (verbData != null)
      return GenerateWordInfo(word: word, data: verbData);
    else if (adjData != null)
      return GenerateWordInfo(word: word, data: adjData);
    else
      return GenerateWordInfo(word: word, data: data.values.first);
  }
}
