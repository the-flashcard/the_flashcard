import 'package:flutter/material.dart';

import 'component.dart';

class TextConfig {
  bool isUpperCase = false;
  bool isUnderline = false;
  int color = Colors.black.value;
  String fontFamily = "HarmoniaSansProCyr";
  int fontWeight = FontWeight.normal.index;
  int fontStyle = FontStyle.normal.index;
  int textAlign = TextAlign.center.index;
  double fontSize = 14.0;
  double letterSpacing = 0.0;
  double wordSpacing = 0.0;
  double lineHeight = 1.0;
  int background = Colors.transparent.value;
  int foreground = 0xffffffff;

  TextConfig();

  TextConfig.from(TextConfig other) {
    if (other is TextConfig) {
      isUpperCase = other.isUpperCase ?? false;
      isUnderline = other.isUnderline ?? false;
      color = other.color ?? Colors.black.value;
      fontFamily = other.fontFamily ?? "HarmoniaSansProCyr";
      fontWeight = other.fontWeight ?? FontWeight.normal.index;
      fontStyle = other.fontStyle ?? FontStyle.normal.index;
      textAlign = other.textAlign ?? TextAlign.left.index;
      fontSize = other.fontSize ?? 14;
      letterSpacing = other.letterSpacing ?? 0.0;
      wordSpacing = other.wordSpacing ?? 0.0;
      lineHeight = other.lineHeight ?? 1.0;
      background = other.background ?? Colors.transparent.value;
      foreground = other.foreground ?? Colors.white.value;
    }
  }

  TextConfig.fromJson(Map<String, dynamic> json) {
    if (json['is_upper_case'] != null) isUpperCase = json['is_upper_case'];
    if (json['is_underline'] != null) isUnderline = json['is_underline'];
    if (json['color'] != null) color = json['color'];
    if (json['font_family'] != null) fontFamily = json['font_family'];
    if (json['font_weight'] != null) fontWeight = json['font_weight'];
    if (json['font_style'] != null) fontStyle = json['font_style'];
    if (json['text_align'] != null) textAlign = json['text_align'];
    if (json['font_size'] != null) fontSize = double.tryParse(json['font_size'].toString());
    if (json['letter_spacing'] != null) letterSpacing = double.tryParse(json['letter_spacing'] .toString());
    if (json['word_spacing'] != null) wordSpacing = double.tryParse(json['word_spacing'] .toString());
    if (json['line_height'] != null) lineHeight = double.tryParse(json['line_height'] .toString());
    if (json['background'] != null) background = json['background'];
    if (json['foreground'] != null) foreground = json['foreground'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['is_upper_case'] = isUpperCase ?? false;
    data['is_underline'] = isUnderline ?? false;
    if (color != null) data['color'] = color;
    if (fontFamily != null) data['font_family'] = fontFamily;
    if (fontWeight != null) data['font_weight'] = fontWeight;
    if (fontStyle != null) data['font_style'] = fontStyle;
    if (textAlign != null) data['text_align'] = textAlign;
    if (fontSize != null) data['font_size'] = fontSize;
    if (letterSpacing != null) data['letter_spacing'] = letterSpacing;
    if (wordSpacing != null) data['word_spacing'] = wordSpacing;
    if (lineHeight != null) data['line_height'] = lineHeight;
    if (background != null) data['background'] = background;
    if (foreground != null) data['foreground'] = foreground;
    return data;
  }

  TextStyle toTextStyle() {
    return TextStyle(
      fontSize: this.fontSize,
      fontFamily: this.fontFamily,
      fontWeight: getFontWeight(this.fontWeight),
      fontStyle: getFontStyle(this.fontStyle),
      color: Color(this.color),
      letterSpacing: this.letterSpacing,
      wordSpacing: this.wordSpacing,
      height: this.lineHeight,
      backgroundColor: Color(this.background),
      decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  TextAlign toTextAlign() {
    return getTextAlign(textAlign);
  }

  static TextAlign getTextAlign(int textAlign) {
    if (textAlign != null) {
      var x = TextAlign.values.where((x) => x.index == textAlign);
      return x.isNotEmpty ? x.first : TextAlign.center;
    } else {
      return TextAlign.center;
    }
  }

  static FontWeight getFontWeight(int fontWeight) {
    if (fontWeight != null) {
      var x = FontWeight.values.where((x) => x.index == fontWeight);
      return x.isNotEmpty ? x.first : FontWeight.normal;
    } else {
      return FontWeight.normal;
    }
  }

  static FontStyle getFontStyle(int fontStyle) {
    if (fontStyle != null) {
      var x = FontStyle.values.where((x) => x.index == fontStyle);
      return x.isNotEmpty ? x.first : FontStyle.normal;
    } else {
      return FontStyle.normal;
    }
  }
}

class Text extends Component {
  String text;
  TextConfig textConfig;

  Text() : super(Component.TextType) {
    textConfig = TextConfig();
  }

  String getText() => text ?? '';

  Text.createWith(this.text, this.textConfig) : super(Component.TextType);

  Text.from(Text other) : super(Component.TextType) {
    if (other != null) {
      textConfig = TextConfig.from(other.textConfig);
      text = other.text;
    }
  }

  Text.fromText({@required this.text, this.textConfig})
      : super(Component.TextType);

  Text.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    text = json['text'] ?? '';
    if (json['text_config'] != null)
      textConfig = TextConfig.fromJson(json['text_config']);
    else
      textConfig = TextConfig();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.text != null) data['text'] = this.text;
    if (this.textConfig != null) data['text_config'] = this.textConfig.toJson();
    return data;
  }

  bool get hasText => text?.trim()?.isNotEmpty ?? false;

  @override
  Text clone() {
    return Text.from(this);
  }

  Text copyWith({
    String text,
    TextConfig textConfig,
  }) {
    return Text.createWith(
      text ?? this.text,
      textConfig ?? this.textConfig,
    );
  }
}
