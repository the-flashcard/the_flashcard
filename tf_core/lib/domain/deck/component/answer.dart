import 'package:tf_core/tf_core.dart';

class Answer extends Component {
  String text = '';
  TextConfig textConfig = TextConfig();
  String imageUrl;
  String audioUrl;
  String videoUrl;
  bool correct = false;

  Answer() : super(Component.AnswerType);

  Answer.from(Answer other) : super(Component.AnswerType) {
    if (other is Answer) {
      text = other.text ?? '';
      textConfig = TextConfig.from(other.textConfig);
      imageUrl = other.imageUrl;
      audioUrl = other.audioUrl;
      videoUrl = other.videoUrl;
      correct = other.correct;
    }
  }

  Answer.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    text = json['text'] ?? '';
    if (json['text_config'] != null)
      textConfig = TextConfig.fromJson(json['text_config']);
    else
      textConfig = TextConfig();
    if (json['image_url'] != null)
      imageUrl = UrlUtils.resolveUploadUrl(json['image_url']);
    if (json['audio_url'] != null)
      audioUrl = UrlUtils.resolveUploadUrl(json['audio_url']);
    if (json['video_url'] != null)
      videoUrl = UrlUtils.resolveUploadUrl(json['video_url']);
    if (json['correct'] != null) correct = json['correct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.text != null) data['text'] = this.text;
    if (this.textConfig != null) data['text_config'] = this.textConfig.toJson();
    if (this.imageUrl != null) data['image_url'] = this.imageUrl;
    if (this.audioUrl != null) data['audio_url'] = this.audioUrl;
    if (this.videoUrl != null) data['video_url'] = this.videoUrl;
    if (this.correct != null) data['correct'] = this.correct;
    return data;
  }

  bool hasUrl() {
    return imageUrl != null || audioUrl != null || videoUrl != null;
  }

  @override
  Answer clone() {
    return Answer.from(this);
  }
}
