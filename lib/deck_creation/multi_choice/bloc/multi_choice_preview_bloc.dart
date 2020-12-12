import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';

class MCPreviewBloc extends Bloc<MCEvent, MCState> {
  @override
  MCState get initialState => InitState();

  @override
  Stream<MCState> mapEventToState(MCEvent event) async* {
    switch (event.runtimeType) {
      case RequestionPreviousEvent:
        yield RequestionPreviousScreen();
        break;
      case CompleteEvent:
        yield CompletedState();
        break;
      default:
        yield CompletedState();
    }
  }
}
