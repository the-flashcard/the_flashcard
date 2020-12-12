import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class RequestionFocusEvent extends Equatable {
  final Key key;

  RequestionFocusEvent(this.key);

  @override
  List<Object> get props => [];

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'RequestionFocusEvent';
}

class RequestionFocusTextEvent extends RequestionFocusEvent {
  RequestionFocusTextEvent(Key key) : super(key);

  @override
  String toString() => 'RequestionFocusTextEvent';
}

//--------------------------------------------------------------------
@immutable
abstract class RequestionFocusState extends Equatable {
  final Key key;

  RequestionFocusState(this.key);

  @override
  List<Object> get props => [key];

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'RequestionFocusState';
}

class InitRequestionFocusState extends RequestionFocusState {
  InitRequestionFocusState() : super(null);

  @override
  String toString() => 'InitState';
}

class RequestionFocusText extends RequestionFocusState {
  RequestionFocusText(Key key) : super(key);

  @override
  String toString() => 'RequestionFocusTextComponent';
}

class RequestionFocusBloc
    extends Bloc<RequestionFocusEvent, RequestionFocusState> {
  RequestionFocusBloc();

  @override
  RequestionFocusState get initialState => InitRequestionFocusState();

  @override
  Stream<RequestionFocusState> mapEventToState(
      RequestionFocusEvent event) async* {
    switch (event.runtimeType) {
      case RequestionFocusTextEvent:
        yield RequestionFocusText(event.key);
        break;
      default:
    }
  }
}
