import 'package:tf_core/tf_core.dart';

class DictionaryRecord {
  DictionaryRecord(
      this.word,
      this.sourceLang,
      this.targetLang,
      this.partOfSpeech,
      this.dictionaryVersion,
      this.data,
      this.creator,
      this.updatedTime,
      this.createdTime);

  String word;

  String sourceLang;

  String targetLang;

  List<String> partOfSpeech;

  int dictionaryVersion;

  Map<String, POSDetailInfo> data;
  String creator;

  BigInt updatedTime;

  BigInt createdTime;

  DictionaryRecord.fromJson(Map<String, dynamic> json) {
    word = json['word'] as String;
    sourceLang = json['source_lang'] as String;
    targetLang = json['target_lang'] as String;
    partOfSpeech =
        (json['part_of_speech'] as List)?.map((e) => e as String)?.toList();
    dictionaryVersion = json['dictionary_version'] as int;
    data = (json['data'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k,
          e == null ? null : POSDetailInfo.fromJson(e as Map<String, dynamic>)),
    );
    creator = json['creator'] as String;
    updatedTime = json['updated_time'] == null
        ? null
        : BigInt.parse(json['updated_time'].toString());
    createdTime = json['created_time'] == null
        ? null
        : BigInt.parse(json['created_time']);
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'source_lang': sourceLang,
      'target_lang': targetLang,
      'part_of_speech': partOfSpeech,
      'dictionary_version': dictionaryVersion,
      'data': data,
      'creator': creator,
      'updated_time': updatedTime,
      'created_time': createdTime
    }..removeWhere((key, value) => value == null);
  }

  @override
  String toString() {
    return "word: $word, source_lang: $sourceLang, $targetLang, $partOfSpeech, ${dictionaryVersion.toString()}, $data, $creator, ${updatedTime.toString()}, ${createdTime.toString()}";
  }
}
