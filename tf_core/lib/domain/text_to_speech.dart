class TextToSpeechResponse {
  String category;
  String lang;
  String text;
  String voicePath;

  TextToSpeechResponse.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    lang = json['lang'];
    text = json['text'];
    voicePath = json['voice_path'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['category'] = this.category;
    data['lang'] = this.lang;
    data['text'] = this.text;
    data['voice_path'] = this.voicePath;
    return data;
  }

  @override
  String toString() {
    return '{${this.category}, ${this.lang}, ${this.text}}';
  }
}
