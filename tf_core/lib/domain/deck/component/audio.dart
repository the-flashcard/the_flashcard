import 'package:tf_core/tf_core.dart';

class Audio extends Component {
  String url;
  String text = "";
  bool useSimpleUi;
  TextConfig textConfig = TextConfig();

  Audio({this.text, this.url})
      : textConfig = TextConfig(),
        super(Component.AudioType);

  Audio.createWith(this.text, this.url, this.textConfig, this.useSimpleUi)
      : super(Component.AudioType);

  Audio.from(Audio other) : super(Component.AudioType) {
    if (other is Audio) {
      this.url = other.url;
      this.text = other.text ?? '';
      this.textConfig = TextConfig.from(other.textConfig);
      this.useSimpleUi = other.useSimpleUi;
    }
  }

  Audio.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['url'] != null) url = UrlUtils.resolveUploadUrl(json['url']);
    if (json['text'] != null) text = json['text'] ?? '';
    if (json['use_simple_ui'] != null) useSimpleUi = json['use_simple_ui'];
    if (json['text_config'] != null)
      textConfig = TextConfig.fromJson(json['text_config']);
    else
      textConfig = TextConfig();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.url != null) data['url'] = this.url;
    data['text'] = this.text ?? '';
    if (this.useSimpleUi != null) data['use_simple_ui'] = this.useSimpleUi;
    if (this.textConfig != null) data['text_config'] = this.textConfig.toJson();
    return data;
  }

  bool get hasUrl => url?.trim()?.isNotEmpty ?? false;

  @override
  Audio clone() {
    return Audio.from(this);
  }

  Audio copyWith({
    String text,
    String url,
    TextConfig textConfig,
    bool useSimpleUi,
  }) {
    return Audio.createWith(
      text ?? this.text,
      url ?? this.url,
      textConfig ?? this.textConfig,
      useSimpleUi ?? this.useSimpleUi,
    );
  }
}
