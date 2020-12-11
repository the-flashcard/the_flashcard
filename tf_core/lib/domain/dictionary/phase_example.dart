class PhraseExample {
  String phrase;
  String audioUrl;

  PhraseExample();

  PhraseExample.createWith(this.phrase, this.audioUrl);

  PhraseExample.from(PhraseExample other) {
    if (other is PhraseExample) {
      phrase = other.phrase;
      audioUrl = other.audioUrl;
    }
  }

  PhraseExample.fromJson(Map<String, dynamic> json) {
    if (json['phrase'] != null) phrase = json['phrase'];
    if (json['audio_url'] != null) audioUrl = json['audio_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.phrase != null) data['phrase'] = this.phrase;
    if (this.toJson != null) data['audio_url'] = this.audioUrl;
    return data;
  }

  PhraseExample copyWith({String phrase, String audioUrl}) {
    return PhraseExample.createWith(
      phrase ?? this.phrase,
      audioUrl ?? this.audioUrl,
    );
  }
}
