import 'package:tf_core/tf_core.dart';

class Translation {
  String meaning;
  String description;
  final List<PhraseExample> examples = [];

  Translation();

  Translation.createWith(
    this.meaning,
    this.description,
    List<PhraseExample> examples,
  ) {
    if (examples != null && examples.isNotEmpty) {
      this.examples.addAll(examples);
    }
  }

  Translation.from(Translation other) {
    if (other is Translation) {
      meaning = other.meaning;
      description = other.description;
      examples.addAll(_clonePhraseExamples(other.examples));
    }
  }

  static List<PhraseExample> _clonePhraseExamples(
      List<PhraseExample> examples) {
    return examples != null
        ? examples.map((example) => PhraseExample.from(example)).toList()
        : [];
  }

  Translation.fromJson(Map<String, dynamic> json) {
    if (json['meaning'] != null) meaning = json['meaning'];
    if (json['description'] != null) description = json['description'];
    if (json['examples'] != null) {
      json['examples']
          .forEach((example) => examples.add(PhraseExample.fromJson(example)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.meaning != null) data['meaning'] = this.meaning;
    if (this.description != null) data['description'] = this.description;
    if (this.examples != null) {
      data['examples'] = this.examples.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Translation copyWith(
      {String meaning, String description, List<PhraseExample> examples}) {
    return Translation.createWith(
      meaning ?? this.meaning,
      description ?? this.description,
      examples ?? this.examples,
    );
  }
}
