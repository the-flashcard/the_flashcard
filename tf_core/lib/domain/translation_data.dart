import 'package:tf_core/tf_core.dart';

class TranslationResponse {
  String text;
  String targetLang;
  String sourceLang;
  String translation;

  TranslationResponse.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    targetLang = json['target_lang'];
    sourceLang = json['source_lang'];
    translation = json['translation'];
  }
}

class SupportedLanguage {
  String code;
  String name;

  SupportedLanguage({this.code, this.name});

  SupportedLanguage.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    name = json["name"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["code"] = this.code;
    data["name"] = this.name;
    return data;
  }

  @override
  String toString() {
    return '{ ${this.code}, ${this.name} }';
  }
}

class XMessageTranslated {
  int _id;
  List<Component> _body = const [];
  final List<int> _indexComponentShowTranslation = [];

  XMessageTranslated(this._id, this._body);

  void registerShowTranslate(int index) {
    _indexComponentShowTranslation.add(index);
  }

  List<int> get indexComponentShowTranslation => _indexComponentShowTranslation;

  int get id => _id;

  List<Component> get body => _body;
}
