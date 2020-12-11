import 'dart:math';

import 'package:tf_core/tf_core.dart';

class ImageConfig {
  static const double MIN_ROTATE = pi * -2;
  static const double MAX_ROTATE = pi * 2;

  static const double MIN_SCALE = 0.03;
  static const double DEF_SCALE = 0.1;
  static const double MAX_SCALE = 1.0;

  static const double MAX_HEIGHT = 500;
  static const double MIN_HEIGHT = 100;
  static const double DEF_HEIGHT = 250;

  double scale = DEF_SCALE;
  double rotate = 0.0;
  double positionX = 0.0;
  double positionY = 0.0;
  double rotationFocusX = 0.0;
  double rotationFocusY = 0.0;
  double height = DEF_HEIGHT;

  ImageConfig();

  ImageConfig.from(ImageConfig other) {
    if (other is ImageConfig) {
      scale = other.scale ?? DEF_SCALE;
      rotate = other.rotate ?? 0.0;
      positionX = other.positionX ?? 0.0;
      positionY = other.positionY ?? 0.0;
      rotationFocusX = other.rotationFocusX ?? 0.0;
      rotationFocusY = other.rotationFocusY ?? 0.0;
      height = other.height ?? DEF_HEIGHT;
    }
  }

  ImageConfig.fromJson(Map<String, dynamic> json) {
    if (json['scale'] != null) scale = json['scale'] ?? DEF_SCALE;
    if (json['rotate'] != null) rotate = json['rotate'] ?? 0.0;
    if (json['position_x'] != null) positionX = json['position_x'] ?? 0.0;
    if (json['position_y'] != null) positionY = json['position_y'] ?? 0.0;
    if (json['rotation_focus_x'] != null)
      rotationFocusX = json['rotation_focus_x'] ?? 0.0;
    if (json['rotation_focus_y'] != null)
      rotationFocusY = json['rotation_focus_y'] ?? 0.0;
    if (json['height'] != null) height = json['height'] ?? DEF_HEIGHT;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (scale != null) data['scale'] = scale;
    if (rotate != null) data['rotate'] = rotate;
    if (positionX != null) data['position_x'] = positionX;
    if (positionY != null) data['position_y'] = positionY;
    if (rotationFocusX != null) data['rotation_focus_x'] = rotationFocusX;
    if (rotationFocusY != null) data['rotation_focus_y'] = rotationFocusY;
    if (height != null) data['height'] = height;
    return data;
  }
}

class Image extends Component {
  String url;
  String text;
  TextConfig textConfig;
  ImageConfig imageConfig;

  Image() : super(Component.ImageType);

  Image.fromConfig(Image componentData, ImageConfig config)
      : super(Component.ImageType) {
    url = componentData?.url;
    text = componentData?.text;
    textConfig = TextConfig.from(componentData.textConfig);
    imageConfig = ImageConfig.from(config);
  }

  Image.from(Image other) : super(Component.ImageType) {
    if (other is Image) {
      url = other.url;
      text = other.text;
      textConfig = TextConfig.from(other.textConfig);
      imageConfig = ImageConfig.from(other.imageConfig);
    }
  }

  Image.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['url'] != null) url = UrlUtils.resolveUploadUrl(json['url']);
    if (json['text'] != null) text = json['text'];

    imageConfig = (json['image_config'] != null)
        ? ImageConfig.fromJson(json['image_config'])
        : ImageConfig();
    if (json['text_config'] != null)
      textConfig = TextConfig.fromJson(json['text_config']);
    else
      textConfig = TextConfig();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.url != null) data['url'] = this.url;
    // if (this.text != null) data['text'] = this.text;
    data['text'] = this.text;
    if (this.imageConfig != null)
      data['image_config'] = this.imageConfig.toJson();
    if (this.textConfig != null)
      data['text_config'] = this.textConfig.toJson();
    else
      data['text_config'] = null;
    return data;
  }

  bool get hasUrl => url?.trim()?.isNotEmpty ?? false;

  Text getTextComponent() {
    return Text()
      ..text = this.text ?? ''
      ..textConfig = this.textConfig ?? TextConfig();
  }

  @override
  Image clone() {
    return Image.from(this);
  }
}
