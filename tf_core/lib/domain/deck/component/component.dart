import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';

export './answer.dart';
export './audio.dart';
export './card_design.dart';
export './container.dart';
export './dictionary.dart';
export './fill_in_blank.dart';
export './image.dart';
export './multi_choice.dart';
export './multi_select.dart';
export './panel.dart';
export './text.dart';
export './video.dart';

abstract class Component {
  static const String TextType = "text";
  static const String ImageType = "image";
  static const String AudioType = "audio";
  static const String VideoType = "video";
  static const String AnswerType = "answer";
  static const String InActiveMultiChoiceType = "inactive_multi_choice";
  static const String MultiChoiceType = "multi_choice";
  static const String MultiSelectType = "multi_select";
  static const String FillInBlankType = "fill_in_blank";
  static const String DictionaryType = "dictionary";
  static const String PanelType = "panel";

  String componentType;

  Component(String componentType) {
    this.componentType = componentType;
  }

  bool get isActionComponent {
    switch (componentType) {
      case MultiChoiceType:
      case MultiSelectType:
      case FillInBlankType:
        return true;
      default:
        return false;
    }
  }

  Component clone();

  Map<String, String> _textsTranslated = {};

  Map<String, String> get textsTranslated => _textsTranslated;

  void setTextsTranslation(Map<String, String> textsTranslated) {
    this._textsTranslated = textsTranslated;
  }

  Component.fromJson(Map<String, dynamic> json) {
    if (json['component_type'] != null) componentType = json['component_type'];
  }

  @mustCallSuper
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.componentType != null) data['component_type'] = this.componentType;
    return data;
  }

  static Component parseComponent(Map<String, dynamic> json) {
    switch (json['component_type']) {
      case Component.TextType:
        return Text.fromJson(json);
      case Component.VideoType:
        return Video.fromJson(json);
      case Component.ImageType:
        return Image.fromJson(json);
      case Component.AudioType:
        return Audio.fromJson(json);
      case Component.InActiveMultiChoiceType:
        return MultiChoice.fromJson(json);
      case Component.MultiChoiceType:
        return MultiChoice.fromJson(json);
      case Component.MultiSelectType:
        return MultiChoice.fromJson(json);
      case Component.AnswerType:
        return Answer.fromJson(json);
      case Component.FillInBlankType:
        return FillInBlank.fromJson(json);
      case Component.DictionaryType:
        return Dictionary.fromJson(json);
      case Component.PanelType:
        return Container.fromJson(json);
      default:
        return null;
    }
  }
}
