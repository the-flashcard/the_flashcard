import 'package:tf_core/tf_core.dart';

abstract class BaseMC extends Component {
  String question = '';
  TextConfig textConfig = TextConfig();
  final List<Answer> answers = [];

  BaseMC(String componentType, {this.question}) : super(componentType);

  BaseMC.from(BaseMC other)
      : super(other?.componentType ?? Component.MultiChoiceType) {
    if (other is BaseMC) {
      question = other.question;
      textConfig = TextConfig.from(other.textConfig);
      answers.addAll(_cloneAnswer(other.answers));
    }
  }

  bool get isActionComponent => true;

  static List<Answer> _cloneAnswer(List<Answer> answers) {
    return answers != null
        ? answers.map((answer) => Answer.from(answer)).toList()
        : [];
  }

  BaseMC.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    question = json['question'] ?? '';
    if (json['text_config'] != null)
      textConfig = TextConfig.fromJson(json['text_config']);
    else
      textConfig = TextConfig();

    json['answers']?.forEach((answer) => answers.add(Answer.fromJson(answer)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.question != null) data['question'] = this.question;
    if (this.textConfig != null) data['text_config'] = this.textConfig.toJson();
    if (this.answers != null) {
      data['answers'] = answers.map((answer) => answer.toJson()).toList();
    }

    return data;
  }

  bool get hasQuestion => question?.trim()?.isNotEmpty ?? false;

  int get countAnswer {
    return answers.fold<int>(0, (count, item) {
      return count + (item?.correct == true ? 1 : 0);
    });
  }

  bool validateAnswers(Set<int> userAnswers) {
    if (userAnswers == null || userAnswers.length != countAnswer)
      return false;
    else {
      int userCountAnswer = userAnswers.fold<int>(
          0,
          (count, item) =>
              count +
              (item >= 0 &&
                      item < answers.length &&
                      answers[item]?.correct == true
                  ? 1
                  : 0));
      return userCountAnswer == countAnswer;
    }
  }

  bool isOnlyText() {
    return answers?.firstWhere(
      (item) => item?.hasUrl() ?? false,
      orElse: () => null,
    ) is Answer
        ? false
        : true;
  }

  bool isMultiOption() {
    return this.getRightAnswerCount() >= 2;
  }

  int getRightAnswerCount() {
    return answers?.where((answer) => answer?.correct == true)?.length ?? 0;
  }

  BaseMC copyWith(
      {String question, TextConfig textConfig, List<Answer> answers});

  Set<int> findMatchingAnswers(List<String> inputTexts) {
    return inputTexts
        .where((s) => s != null)
        .map((s) => s.toLowerCase().trim())
        .where((s) => s.isNotEmpty)
        .map((answerText) {
      return answers
          .asMap()
          .entries
          .where(
              (entry) => entry.value?.text?.toLowerCase()?.trim() == answerText)
          .map<int>((entry) => entry.key)
          .firstWhere((_) => true, orElse: () => 10000);
    }).toSet();
  }
}

class MultiChoice extends BaseMC {
  MultiChoice({String question})
      : super(Component.MultiChoiceType, question: question);

  MultiChoice.createWith(
    String question,
    TextConfig textConfig,
    List<Answer> answers,
  ) : super(Component.MultiChoiceType, question: question) {
    textConfig = textConfig;
    if (answers != null && answers.isNotEmpty) this.answers.addAll(answers);
  }

  MultiChoice.from(MultiChoice other) : super.from(other);

  MultiChoice.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    return data;
  }

  @override
  MultiChoice clone() {
    return MultiChoice.from(this);
  }

  MultiChoice addAnswers(List<Answer> answers) {
    this.answers.addAll(answers);
    return this;
  }

  @override
  BaseMC copyWith(
      {String question, TextConfig textConfig, List<Answer> answers}) {
    return MultiChoice.createWith(
      question ?? this.question,
      textConfig ?? this.textConfig,
      answers ?? this.answers,
    );
  }
}
