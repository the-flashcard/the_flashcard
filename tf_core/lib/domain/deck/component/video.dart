import 'package:tf_core/tf_core.dart';

class Video extends Component {
  String url;
  String text = '';
  VideoConfig config;

  Video() : super(Component.VideoType);

  Video.createWith(this.url, this.text, this.config)
      : super(Component.VideoType);

  Video.from(Video other) : super(Component.VideoType) {
    if (other is Video) {
      url = other.url;
      text = other.text ?? '';
      config = VideoConfig.from(other.config);
    }
  }

  Video.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['url'] != null) url = UrlUtils.resolveUploadUrl(json['url']);
    text = json['text'] ?? '';
    if (json['text_config'] != null)
      this.config = VideoConfig.fromJson(json['text_config']);
    else
      this.config = VideoConfig.init();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.url != null) data['url'] = this.url;
    if (this.text != null) data['text'] = this.text;
    if (this.config != null) data['text_config'] = this.config.toJson();

    return data;
  }

  bool get hasUrl => url?.trim()?.isNotEmpty ?? false;

  @override
  Video clone() {
    return Video.from(this);
  }

  Video copyWith({String url, String text = '', VideoConfig config}) {
    return Video.createWith(
      url ?? this.url,
      text ?? this.text,
      config ?? this.config,
    );
  }
}

class VideoConfig {
  static const double MAX_HEIGHT = 450;
  static const double MIN_HEIGHT = 140;
  static const double DEF_HEIGHT = 150;

  double height = DEF_HEIGHT;

  VideoConfig.from(VideoConfig other) {
    if (other is VideoConfig) {
      this.height = other.height;
    }
  }

  VideoConfig.init() {
    this.height = DEF_HEIGHT;
  }

  VideoConfig.fromJson(Map<String, dynamic> json) {
    height = json['height'] ?? DEF_HEIGHT;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'height': height ?? DEF_HEIGHT,
    };

    return data;
  }
}
