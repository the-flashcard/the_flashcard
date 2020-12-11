import 'package:flutter/material.dart' as material;
import 'package:tf_core/tf_core.dart';

class FillInBlank extends Component {
  String question = '';
  TextConfig textConfig = TextConfig();
  final List<String> correctAnswers = [];

  FillInBlank() : super(Component.FillInBlankType);

  FillInBlank.fromQuestionAndAnswers(this.question, List<String> correctAnswers,
      {this.textConfig})
      : super(Component.FillInBlankType) {
    this.correctAnswers.addAll(correctAnswers);
  }

  FillInBlank.from(FillInBlank other) : super(Component.FillInBlankType) {
    if (other is FillInBlank) {
      question = other.question ?? '';
      textConfig = TextConfig.from(other.textConfig);
      correctAnswers.addAll(other.correctAnswers ?? []);
    }
  }

  FillInBlank.create() : super(Component.FillInBlankType) {
    this
      ..question = ''
      ..textConfig = (TextConfig()
        ..textAlign = material.TextAlign.left.index
        ..fontSize = 16
        ..fontWeight = material.FontWeight.normal.index);
  }

  FillInBlank.createWith(
    this.question,
    this.textConfig,
    List<String> correctAnswers,
  ) : super(Component.FillInBlankType) {
    if (correctAnswers != null && correctAnswers.isNotEmpty) {
      this.correctAnswers.addAll(correctAnswers);
    }
  }

  FillInBlank.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    question = json['question'] ?? '';
    if (json['text_config'] != null)
      textConfig = TextConfig.fromJson(json['text_config']);
    else
      textConfig = TextConfig();
    if (json['correct_answers'] != null) {
      json['correct_answers'].forEach((answer) => correctAnswers.add(answer));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.question != null) data['question'] = this.question;
    if (this.textConfig != null) data['text_config'] = this.textConfig.toJson();
    if (this.correctAnswers != null)
      data['correct_answers'] = this.correctAnswers;
    return data;
  }

  bool get isActionComponent => true;

  bool validateAnswers(List<String> userAnswers) {
    if (userAnswers == null)
      return false;
    else {
      int correctCount = correctAnswers
          .asMap()
          .keys
          .map((index) {
            return (index < userAnswers.length)
                ? validateAnswer(index, userAnswers[index])
                : false;
          })
          .where((x) => x)
          .length;

      return correctCount == correctAnswers.length;
    }
  }

  bool validateAnswer(int index, String userAnswer) {
    if (index >= 0 && index < correctAnswers.length) {
      return userAnswer != null &&
          correctAnswers[index].trim().toLowerCase() ==
              userAnswer.trim().toLowerCase();
    }
    return false;
  }

  bool get hasQuestion => question?.trim()?.isNotEmpty ?? false;

  @override
  FillInBlank clone() {
    return FillInBlank.from(this);
  }

  FillInBlank copyWith({
    String question,
    TextConfig textConfig,
    List<String> correctAnswers,
  }) {
    return FillInBlank.createWith(
      question ?? this.question,
      textConfig ?? this.textConfig,
      correctAnswers ?? this.correctAnswers,
    );
  }
}
