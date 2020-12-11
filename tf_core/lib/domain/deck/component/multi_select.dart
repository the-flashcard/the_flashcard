import 'package:tf_core/tf_core.dart';

class MultiSelect extends BaseMC {
  MultiSelect() : super(Component.MultiSelectType);

  MultiSelect.createWith(
    String question,
    TextConfig textConfig,
    List<Answer> answers,
  ) : super(Component.MultiSelectType, question: question) {
    textConfig = textConfig;
    if (answers != null && answers.isNotEmpty) {
      this.answers.addAll(answers);
    }
  }

  MultiSelect.from(MultiSelect other) : super.from(other);

  MultiSelect.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();

    return data;
  }

  @override
  MultiSelect clone() {
    return MultiSelect.from(this);
  }

  bool get isActionComponent => true;

  @override
  BaseMC copyWith(
      {String question, TextConfig textConfig, List<Answer> answers}) {
    return MultiSelect.createWith(
      question ?? this.question,
      textConfig ?? this.textConfig,
      answers ?? this.answers,
    );
  }
}
