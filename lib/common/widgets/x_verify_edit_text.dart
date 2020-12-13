import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';

@immutable
class XVerifyEditTextView extends StatefulWidget {
  final TextEditingController controller;
  final void Function(List<String> digits) onCompleted;
  final void Function(List<String> digits) onUnCompleted;
  final int totalNumberOfDigits;

  XVerifyEditTextView({
    @required this.totalNumberOfDigits,
    this.controller,
    this.onCompleted,
    this.onUnCompleted,
  });

  @override
  _XVerifyEditTextViewState createState() => _XVerifyEditTextViewState();
}

class _XVerifyEditTextViewState extends State<XVerifyEditTextView> {
  VerifyFieldBloc bloc;
  final List<FocusNode> focusList = [];
  final List<TextEditingController> boxControllers = [];

  @override
  void initState() {
    super.initState();

    bloc = VerifyFieldBloc(widget.totalNumberOfDigits);
    for (int i = 0; i < widget.totalNumberOfDigits; i++) {
      boxControllers.add(TextEditingController());
      focusList.add(
          FocusNode(onKey: (node, event) => _onBoxKeyDown(i, node, event)));
    }
  }

  bool _onBoxKeyDown(int pos, FocusNode node, RawKeyEvent event) {
    final controller = boxControllers[pos];

    if (event.logicalKey == LogicalKeyboardKey.delete ||
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (controller.text.isNotEmpty)
        controller.text = '';
      else if (pos > 0) {
        FocusScope.of(context).requestFocus(focusList[pos - 1]);
        node.unfocus();
      }
      return false;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (pos > 0) {
        FocusScope.of(context).requestFocus(focusList[pos - 1]);
        node.unfocus();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (pos < (widget.totalNumberOfDigits - 1)) {
        FocusScope.of(context).requestFocus(focusList[pos + 1]);
        node.unfocus();
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;

    Widget _buildBox(BuildContext context, VerifyFieldState state, int pos) {
      return Container(
        width: wp(40),
        height: wp(40),
        decoration: BoxDecoration(
          border: Border.all(
            color: (!state.isFirstInit && state.errorPos().contains(pos))
                ? Colors.red
                : Color.fromRGBO(0, 0, 0, 0.1),
          ),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: TextField(
          controller: boxControllers[pos],
          focusNode: focusList[pos],
          cursorColor: XedColors.waterMelon,
          decoration:
              InputDecoration(border: InputBorder.none, counterText: ''),
          keyboardType: TextInputType.number,
          maxLength: 1,
          minLines: 1,
          textAlign: TextAlign.center,
          onChanged: (String text) =>
              XError.f0(() => _onDigitBoxChanged(context, pos, text)),
        ),
      );
    }

    return BlocListener(
      cubit: bloc,
      listener: (context, state) => _onStateChanged(context, state),
      child: BlocBuilder<VerifyFieldBloc, VerifyFieldState>(
        cubit: bloc,
        builder: (BuildContext context, VerifyFieldState state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                List.generate(widget.totalNumberOfDigits, (pos) => pos).fold(
              <Widget>[],
              (widgets, pos) {
                widgets.add(_buildBox(context, state, pos));
                if (pos < (widget.totalNumberOfDigits - 1))
                  widgets.add(SizedBox(width: 10));
                return widgets;
              },
            ),
          );
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, VerifyFieldState state) {
    widget.controller?.text = state.digits.join();
    if (state.isValid()) {
      widget?.onCompleted(state.digits);
    } else {
      widget?.onUnCompleted(state.digits);
    }
  }

  void _onDigitBoxChanged(BuildContext context, int pos, String text) {
    bloc.add(DigitChanged(pos: pos, digit: text));
    if (text.length == 1 && pos < (widget.totalNumberOfDigits - 1)) {
      FocusScope.of(context).requestFocus(focusList[pos + 1]);
    } else if (text.isEmpty && pos > 0) {
      FocusScope.of(context).requestFocus(focusList[pos - 1]);
    }
  }

  @override
  void dispose() {
    boxControllers
      ..forEach((controller) => controller?.dispose())
      ..clear();
    super.dispose();
  }
}

class VerifyFieldState extends Equatable {
  final bool isFirstInit;
  final int totalNumberOfDigits;
  final List<String> digits;

  @override
  List<Object> get props => [
        isFirstInit,
        digits,
        totalNumberOfDigits,
      ];

  VerifyFieldState(
      {@required this.isFirstInit,
      @required this.digits,
      this.totalNumberOfDigits = 6});

  bool isValid() => errorPos().isEmpty;

  Set<int> errorPos() {
    return digits
        .asMap()
        .entries
        .where((x) => x.value == null || x.value.trim().isEmpty)
        .map<int>((x) => x.key)
        .toSet();
  }

  factory VerifyFieldState.empty({
    totalNumberOfDigits = 6,
  }) {
    return VerifyFieldState(
      isFirstInit: true,
      digits:
          List.generate(totalNumberOfDigits, (i) => i).fold(<String>[], (l, e) {
        l.add('');
        return l;
      }),
      totalNumberOfDigits: totalNumberOfDigits,
    );
  }

  VerifyFieldState copyWith({
    bool isFirstInit,
    List<String> digits,
    int totalNumberOfDigits,
  }) {
    return VerifyFieldState(
      isFirstInit: isFirstInit ?? this.isFirstInit,
      digits: digits ?? this.digits,
      totalNumberOfDigits: totalNumberOfDigits ?? this.totalNumberOfDigits,
    );
  }

  @override
  String toString() => '${this.runtimeType.toString()}: ${digits.join()}';
}

abstract class VerifyFieldEvent extends Equatable {
  VerifyFieldEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class DigitChanged extends VerifyFieldEvent {
  final int pos;
  final String digit;

  DigitChanged({@required this.pos, @required this.digit})
      : super([pos, digit]);

  @override
  String toString() => 'DigitChanged {pos:  $pos}';
}

class DigitDeleted extends VerifyFieldEvent {
  final int pos;

  DigitDeleted({@required this.pos}) : super([pos]);

  @override
  String toString() => 'DigitDeleted';
}

class VerifyFieldBloc extends Bloc<VerifyFieldEvent, VerifyFieldState> {
  final int totalNumberOfDigits;

  VerifyFieldBloc(this.totalNumberOfDigits)
      : super(VerifyFieldState.empty(totalNumberOfDigits: totalNumberOfDigits));

  @override
  Stream<VerifyFieldState> mapEventToState(VerifyFieldEvent event) async* {
    switch (event.runtimeType) {
      case DigitChanged:
        yield* _onDigitChanged(event);
        break;
      case DigitDeleted:
        yield* _onDigitDeleted(event);
        break;
    }
  }

  Stream<VerifyFieldState> _onDigitChanged(DigitChanged event) async* {
    var digits = <String>[...state.digits];
    digits[event.pos] = event.digit;
    yield state.copyWith(isFirstInit: false, digits: digits);
  }

  Stream<VerifyFieldState> _onDigitDeleted(DigitChanged event) async* {
    var digits = <String>[...state.digits];
    digits[event.pos] = '';
    yield state.copyWith(isFirstInit: false, digits: digits);
  }
}
