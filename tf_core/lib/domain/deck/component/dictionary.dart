import 'package:tf_core/tf_core.dart';

class Dictionary extends Component {
  String word;
  String partOfSpeech;
  final List<Pronunciation> pronunciations = [];
  final List<Translation> translations = [];
  final List<String> images = [];

  Dictionary() : super(Component.DictionaryType);

  Dictionary.createWith(
      this.word,
      this.partOfSpeech,
      List<Pronunciation> pronunciations,
      List<Translation> translations,
      List<String> images)
      : super(Component.DictionaryType) {
    if (pronunciations != null && pronunciations.isNotEmpty)
      this.pronunciations.addAll(pronunciations);
    if (translations != null && translations.isNotEmpty)
      this.translations.addAll(translations);
    if (images != null && images.isNotEmpty) this.images.addAll(images);
  }

  Dictionary.from(Dictionary other) : super(Component.DictionaryType) {
    if (other is Dictionary) {
      word = other.word;
      partOfSpeech = other.partOfSpeech;
      pronunciations.addAll(_clonePronunciations(other.pronunciations));
      translations.addAll(_cloneTranslations(other.translations));
      images.addAll(other.images ?? []);
    }
  }

  List<Pronunciation> _clonePronunciations(List<Pronunciation> pronunciations) {
    return pronunciations != null
        ? pronunciations
            .map((pronunciation) => Pronunciation.from(pronunciation))
            .toList()
        : [];
  }

  List<Translation> _cloneTranslations(List<Translation> translation) {
    return translation != null
        ? translation
            .map((pronunciation) => Translation.from(pronunciation))
            .toList()
        : [];
  }

  Dictionary.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['word'] != null) word = json['word'];
    if (json['part_of_speech'] != null) partOfSpeech = json['part_of_speech'];
    if (json['pronunciations'] != null) {
      json['pronunciations'].forEach((pronunciation) =>
          pronunciations.add(Pronunciation.fromJson(pronunciation)));
    }
    if (json['translations'] != null) {
      json['translations'].forEach(
          (translation) => translations.add(Translation.fromJson(translation)));
    }
    if (json['images'] != null) {
      json['images'].forEach((image) => images.add(image));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.word != null) data['word'] = this.word;
    if (this.partOfSpeech != null) data['part_of_speech'] = this.partOfSpeech;
    if (this.pronunciations != null) {
      data['pronunciations'] =
          this.pronunciations.map((v) => v.toJson()).toList();
    }
    if (this.translations != null) {
      data['translations'] = this.translations.map((v) => v.toJson()).toList();
    }
    if (this.images != null) data['images'] = this.images;
    return data;
  }

  String get phoneticFirst {
    if (pronunciations?.isNotEmpty ?? false) {
      var pron = pronunciations.firstWhere((pron) {
        return pron.region.toLowerCase() == "us";
      }, orElse: () => pronunciations.first);

      return pron.phoneticTranscription ?? '';
    }
    return '';
  }

  String get audioUrlFirst {
    if (pronunciations?.isNotEmpty ?? false) {
      var pron = pronunciations.firstWhere((pron) {
        return pron.region.toLowerCase() == "us";
      }, orElse: () => pronunciations.first);

      return pron.audioUrl ?? '';
    }
    return '';
  }

  String get imageFirst {
    if (images?.isNotEmpty ?? false) {
      return images.first ?? '';
    }
    return '';
  }

  @override
  Dictionary clone() {
    return Dictionary.from(this);
  }

  Dictionary copyWith({
    String word,
    String partOfSpeech,
    List<Pronunciation> pronunciations,
    List<Translation> translations,
    List<String> images,
  }) {
    return Dictionary.createWith(
      word ?? this.word,
      partOfSpeech ?? this.partOfSpeech,
      pronunciations ?? this.pronunciations,
      translations ?? this.translations,
      images ?? this.images,
    );
  }
}
