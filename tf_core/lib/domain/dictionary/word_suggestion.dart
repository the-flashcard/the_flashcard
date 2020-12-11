class WordSuggestion {
  WordSuggestion(this.word, this.sourceLang, this.targetLang);

  String word;
  String sourceLang;

  String targetLang;

  WordSuggestion.fromJson(Map<String, dynamic> json) {
    word = json['word'] as String;
    sourceLang = json['source_lang'] as String;
    targetLang = json['target_lang'] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'source_lang': sourceLang,
      'target_lang': targetLang,
    }..removeWhere((key, value) => value == null);
  }

  @override
  String toString() {
    return "{ \"word\": $word, src_lang: $sourceLang, target_lang: $targetLang}";
  }
}
