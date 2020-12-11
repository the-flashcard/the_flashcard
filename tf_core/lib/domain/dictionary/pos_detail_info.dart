import 'package:tf_core/tf_core.dart';

class POSDetailInfo {
  POSDetailInfo(this.pronunciations, this.translations, [this.images]);

  List<Pronunciation> pronunciations;

  List<Translation> translations;

  List<String> images;

  POSDetailInfo.fromJson(Map<String, dynamic> json) {
    pronunciations = (json['pronunciations'] as List)
        ?.map((e) => e == null
            ? null
            : Pronunciation.fromJson(e as Map<String, dynamic>))
        ?.toList();
    translations = (json['translations'] as List)
        ?.map((e) =>
            e == null ? null : Translation.fromJson(e as Map<String, dynamic>))
        ?.toList();
    images = (json['images'] as List)?.map((e) => e as String)?.toList();
  }

  Map<String, dynamic> toJson() {
    final pronunciations =
        this.pronunciations?.map((e) => e?.toJson())?.toList();
    pronunciations?.removeWhere((element) => element == null);
    final translations = this.translations?.map((e) => e?.toJson())?.toList();
    translations?.removeWhere((element) => element == null);

    return {
      'pronunciations': pronunciations,
      'translations': translations,
      'images': images
    }..removeWhere((key, value) => value == null);
  }
}
