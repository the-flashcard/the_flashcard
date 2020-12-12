import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';

class ButtonMoreOptionWidget extends StatefulWidget {
  ButtonMoreOptionWidget({Key key}) : super(key: key);

  @override
  _ButtonMoreOptionWidgetState createState() => _ButtonMoreOptionWidgetState();
}

class _ButtonMoreOptionWidgetState extends State<ButtonMoreOptionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: XedColors.skyColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          onTap: () => XError.f0(_onTapAddAnswer),
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(Icons.add, color: XedColors.azureColor, size: 20),
              Text(
                'MORE OPTION',
                style: SemiBoldTextStyle(12)
                    .copyWith(color: XedColors.azureColor, height: 1.4),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onTapAddAnswer() {
    BlocProvider.of<MCStepOneBloc>(context).add(UnfocusedEvent());
    BlocProvider.of<MCStepOneBloc>(context).add(ClickAddAnswerOptionEvent());
  }
}
