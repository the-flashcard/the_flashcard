import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tf_core/tf_core.dart';

import 'multi_choice_bloc.dart';

class MCStepTwoBloc extends Bloc<MCEvent, MCState> {
  List<Answer> get answers => choice.answers;
  MultiChoice choice;

  MCStepTwoBloc.edit(this.choice) {
    _getCorrectAnswer();
    nextScreen = _choices.isNotEmpty;
  }
  @override
  MCState get initialState => InitState();

  void _getCorrectAnswer() {
    choice.answers.forEach((item) {
      if (item.correct) _choices.add(item);
    });
  }

  bool isRadioButton = false;

  bool nextScreen = false;

  final Set<Answer> _choices = Set<Answer>();

  Stream<MCState> _choiceAnswer(ChoiceAnswerEvent event) async* {
    if (_choices.contains(event.answer)) {
      event.answer.correct = false;
      _choices.remove(event.answer);
    } else {
      event.answer.correct = true;
      _choices.add(event.answer);
    }

    yield* _controllNextButton();
  }

  Stream<MCState> _controllNextButton() async* {
    if (!nextScreen && _choices.isNotEmpty) {
      nextScreen = true;
      yield RequestionNextOn();
      return;
    }

    if (nextScreen && _choices.isEmpty) {
      nextScreen = false;
      yield RequestionNextOff();
      return;
    }
  }

  @override
  Stream<MCState> mapEventToState(MCEvent event) async* {
    switch (event.runtimeType) {
      case ChoiceAnswerEvent:
        yield* _choiceAnswer(event);
        break;
      case RequestionPreviousEvent:
        yield RequestionPreviousScreen();
        break;
      case RequestionNextEvent:
        yield RequestionNextScreen(answers: choice);
        break;
      default:
        yield CompletedState();
    }
  }
}
