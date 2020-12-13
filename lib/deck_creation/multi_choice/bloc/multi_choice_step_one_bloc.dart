import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';

class MCStepOneBloc extends Bloc<MCEvent, MCState> {
  final core.MultiChoice _model;
  final _componentsHasValue = Set<core.Answer>();
  bool hasQuestion = false;

  List<core.Answer> get answers => _model.answers;

  core.MultiChoice get model => _model;

  MCStepOneBloc.create()
      : _model = core.MultiChoice(),
        super(InitState()) {
    _model.textConfig
      ..textAlign = TextAlign.left.index
      ..fontSize = 18
      ..fontWeight = FontWeight.bold.index;

    var answer = core.Answer();
    _addConfig(answer);
    answers.add(answer);
    _next = RequestionNextOff();
  }

  void _addConfig(core.Answer answer) {
    answer.textConfig
      ..textAlign = TextAlign.left.index
      ..fontSize = 14
      ..fontWeight = FontWeight.normal.index;
  }

  MCStepOneBloc.edit(this._model)
      : _next = RequestionNextOn(),
        super(InitState()) {
    _componentsHasValue.addAll(this._model.answers);
    hasQuestion = true;
  }
  FocusedState get focused => _focused;
  FocusedState _focused;

  MCState get nextState => _next;
  MCState _next;

  Stream<MCState> _addAnswerOptionWidget() async* {
    var answer = core.Answer();
    _addConfig(answer);
    answers.add(answer);
    yield AddAnswerOption(answer);
  }

  Stream<MCState> _deleteAnswerOptionWidget(
      DeleteAnswerOptionEvent event) async* {
    answers.remove(event.widget.answer);
    _componentsHasValue.remove(event.widget.answer); //Success
    yield DeleteAnswerOption(event.widget);
  }

  // @override
  // Stream<MCState> transformEvents(
  //     Stream<MCEvent> events, Stream<MCState> Function(MCEvent p1) next) {
  //   bool isDebounce(MCEvent event) {
  //     switch (event.runtimeType) {
  //       case EditingAnswerEvent:
  //         return true;
  //       default:
  //         return false;
  //     }
  //   }

  //   final nonDebounceStream = events.where((event) => !isDebounce(event));

  //   final debounceStream = events
  //       .where((event) => isDebounce(event))
  //       .debounceTime(Duration(milliseconds: 300));
  //   return super
  //       .transformEvents(nonDebounceStream.mergeWith([debounceStream]), next);
  // }

  void _editingAnswer(String str, core.Answer answer) {
    if (answer.hasUrl() || (str != null && str.isNotEmpty)) {
      _componentsHasValue.add(answer);
    } else {
      _componentsHasValue.remove(answer);
    }

    controlButtonNext();
  }

  void _editingQuestion(String str) {
    _model.question = str;
    hasQuestion = str != null ? str.isNotEmpty : false;
    if (state.runtimeType is RequestionNextOnEvent) return;
    controlButtonNext();
  }

  void controlButtonNext() {
    if (_componentsHasValue.isNotEmpty && hasQuestion) {
      if (state is RequestionNextOn) return;
      add(RequestionNextOnEvent());
    } else {
      if (state is RequestionNextOff) return;
      add(RequestionNextOffEvent());
    }
  }

  @override
  Stream<MCState> mapEventToState(MCEvent event) async* {
    if (event is EditingAnswerEvent) {
      _editingAnswer(event.answer.text, event.answer);
      return;
    }
    switch (event.runtimeType) {
      case ReLoadAnwserListEvent:
        yield ReLoadAnwserList();
        break;
      case FocusedEvent:
        var focus = event as FocusedEvent;
        yield _focused = FocusedState(
          node: focus.node,
          config: focus.textConfig,
          onConfigChanged: focus.onConfigChanged,
        );
        break;
      case UnfocusedEvent:
        yield UnfocusedState();
        break;
      case DeleteAnswerOptionEvent:
        yield* _deleteAnswerOptionWidget(event);
        controlButtonNext();
        break;
      case ClickAddAnswerOptionEvent:
        yield* _addAnswerOptionWidget();
        break;

      case EditingQuestionEvent:
        _editingQuestion(event.props.first);
        break;
      case RequestionNextOnEvent:
        yield _next = RequestionNextOn();
        break;
      case RequestionNextOffEvent:
        yield _next = RequestionNextOff();
        break;
      case RequestionNextEvent:
        yield RequestionNextScreen(
          answers: core.MultiChoice()
            ..answers.addAll(this._componentsHasValue)
            ..question = this._model.question
            ..textConfig = this.model.textConfig,
        );
        break;
      case RequestionOpenTextEditingEvent:
        yield RequestionOpenTextEditing(event.props.first);
        break;
      default:
        yield EditQuestionAnswer();
    }
  }
}
