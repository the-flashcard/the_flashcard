import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/deck_creation/multi_choice/answer_option_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';

@immutable
abstract class MCEvent extends Equatable {
  MCEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class ClickAddAnswerOptionEvent extends MCEvent {
  @override
  String toString() => 'ClickAddAnswerOptionEvent';
}

class DeleteAnswerOptionEvent extends MCEvent {
  final AnswerOptionWidget widget;

  DeleteAnswerOptionEvent(this.widget) : super([widget]);

  @override
  String toString() => 'DeleteAnswerOptionEvent';
}

class CompleteEvent extends MCEvent {
  final core.MultiChoice model;

  CompleteEvent(this.model) : super([model]);

  @override
  String toString() => 'CompleteEvent';
}

class EditingQuestionEvent extends MCEvent {
  EditingQuestionEvent(String str) : super([str]);

  @override
  String toString() => 'EditingQuestionEvent';
}

class EditingAnswerEvent extends MCEvent {
  final core.Answer answer;
  final String str;

  EditingAnswerEvent(this.str, this.answer) : super([str, answer]);

  @override
  String toString() => 'EditingAnswerEvent';
}

class AddImangeEvent extends EditingAnswerEvent {
  final core.Answer answer;

  AddImangeEvent(this.answer) : super(answer.text, answer);

  @override
  String toString() => 'AddImangeEvent';
}

class RemoveImangeEvent extends EditingAnswerEvent {
  final core.Answer answer;

  RemoveImangeEvent(this.answer) : super(answer.text, answer);

  @override
  String toString() => 'RemoveImangeEvent';
}

class AddAudioEvent extends EditingAnswerEvent {
  final core.Answer answer;

  AddAudioEvent(this.answer) : super(answer.text, answer);

  @override
  String toString() => 'AddAudioEvent';
}

class RemoveAudioEvent extends EditingAnswerEvent {
  final core.Answer answer;

  RemoveAudioEvent(this.answer) : super(answer.text, answer);

  @override
  String toString() => 'RemoveAudioEvent';
}

class RequestionNextOnEvent extends MCEvent {
  @override
  String toString() => 'RequestionNextOnEvent';
}

class RequestionNextOffEvent extends MCEvent {
  @override
  String toString() => 'RequestionNextOffEvent';
}

class RequestionNextEvent extends MCEvent {
  @override
  String toString() => 'RequestionNextEvent';

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => this.runtimeType.hashCode;
}

class RequestionPreviousEvent extends MCEvent {
  @override
  String toString() => 'RequestionPreviousEvent';

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => this.runtimeType.hashCode;
}

class FocusedEvent extends MCEvent {
  final core.TextConfig textConfig;
  final FocusNode node;
  final TextConfigChanged onConfigChanged;

  FocusedEvent({
    @required this.node,
    @required this.textConfig,
    @required this.onConfigChanged,
  }) : super([node, textConfig, onConfigChanged]);

  @override
  String toString() => 'FocusedEvent';
}

class UnfocusedEvent extends MCEvent {
  @override
  String toString() => 'UnfocusedEvent';
}

class ChoiceAnswerEvent extends MCEvent {
  final core.Answer answer;

  ChoiceAnswerEvent(this.answer) : super([answer]);

  @override
  String toString() => 'ChoiceAnswerEvent';
}

class RequestionOpenTextEditingEvent extends MCEvent {
  final core.TextConfig config;

  RequestionOpenTextEditingEvent(this.config) : super([config]);

  @override
  String toString() => 'ReuqestionOpenEditingEvent';
}

class ReLoadAnwserListEvent extends MCEvent {
  ReLoadAnwserListEvent();

  @override
  String toString() => 'ReLoadAnwserListEvent';
}
