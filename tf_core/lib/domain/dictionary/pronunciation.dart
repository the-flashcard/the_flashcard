class Pronunciation {
  String region;
  String phoneticTranscription;
  String audioUrl;

  Pronunciation();

  Pronunciation.from(Pronunciation other) {
    if (other is Pronunciation) {
      region = other.region;
      phoneticTranscription = other.phoneticTranscription;
      audioUrl = other.audioUrl;
    }
  }

  Pronunciation.fromJson(Map<String, dynamic> json) {
    if (json['region'] != null) region = json['region'];
    if (json['phonetic_transcription'] != null)
      phoneticTranscription = json['phonetic_transcription'];
    if (json['audio_url'] != null) audioUrl = json['audio_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.region != null) data['region'] = this.region;
    if (this.phoneticTranscription != null)
      data['phonetic_transcription'] = this.phoneticTranscription;
    if (this.audioUrl != null) data['audio_url'] = this.audioUrl;
    return data;
  }
}
