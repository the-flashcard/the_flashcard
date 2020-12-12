import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/deck_creation/multi_choice/answer_option_widget.dart';

@immutable
abstract class MCState extends Equatable {
  MCState([this.props = const []]);

  @override
  final List<Object> props;
}

class InitState extends MCState {
  @override
  String toString() => 'InitState';
}

class RequestionChangeButton extends MCState {
  final bool isRadioButton;

  RequestionChangeButton({@required this.isRadioButton})
      : super([isRadioButton]);

  @override
  String toString() => 'RequestionChangeButton';
}

class ReLoadAnwserList extends MCState {
  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ReLoadAnwserList';
}

class RequestionNextScreen extends MCState {
  final MultiChoice answers;

  RequestionNextScreen({@required this.answers}) : super([answers]);

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => this.runtimeType.hashCode;

  @override
  String toString() => 'RequestionNext';
}

class RequestionPreviousScreen extends MCState {
  @override
  String toString() => 'RequestionPrevious';

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => this.runtimeType.hashCode;
}

class EditQuestionAnswer extends MCState {
  @override
  String toString() => 'EditQuestion';
}

class CompletedState extends MCState {
  final MultiChoice component;

  CompletedState({this.component}) : super([component]);

  @override
  String toString() => 'CompletedState';
}

class RequestionNextOn extends MCState {
  @override
  String toString() => 'RequestionNextOn';
}

class RequestionNextOff extends MCState {
  @override
  String toString() => 'RequestionNextOff';
}

class RequestionPreOn extends MCState {
  @override
  String toString() => 'RequestionPreOn';
}

class RequestionPreOff extends MCState {
  @override
  String toString() => 'RequestionPreOff';
}

typedef TextConfigChanged = void Function(TextConfig, bool);

class FocusedState extends MCState {
  final FocusNode node;
  final TextConfig config;
  final TextConfigChanged onConfigChanged;

  FocusedState({this.node, this.config, this.onConfigChanged})
      : super([node, config, onConfigChanged]);

  @override
  String toString() => 'FocusedState';
}

class UnfocusedState extends MCState {
  @override
  String toString() => 'UnfocusedState';
}

class ChoiceAnswer extends MCState {
  @override
  String toString() => 'ChoiceAnswer';
}

class RequestionAddImange extends MCState {
  final String url;
  final Answer answer;

  RequestionAddImange(this.url, this.answer) : super([url]);

  @override
  String toString() => 'RequestionAddImange';
}

class RequestionRemoveImange extends MCState {
  final Answer answer;

  RequestionRemoveImange(this.answer) : super([answer]);

  @override
  String toString() => 'RequestionRemoveImange';
}

class RequestionOpenTextEditing extends MCState {
  final TextConfig config;

  RequestionOpenTextEditing(this.config) : super([config]);

  @override
  String toString() => 'ReuqestionOpenEditing';
}

class RequestionCloseTextEditing extends MCState {
  @override
  String toString() => 'RequestionCloseTextEditing';
}

class AddAnswerOption extends MCState {
  final Answer component;

  AddAnswerOption(this.component) : super([component]);

  @override
  String toString() => 'AddAnswerOption';
}

class DeleteAnswerOption extends MCState {
  final AnswerOptionWidget component;

  DeleteAnswerOption(this.component) : super([component]);

  @override
  String toString() => 'RemoveAnswerOption';
}
