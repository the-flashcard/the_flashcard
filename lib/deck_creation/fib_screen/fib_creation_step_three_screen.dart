import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/widgets/appbar_step_three_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_component_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_fib_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bottom_action_bar_widget.dart';

class FIBCreationStepThreeScreen extends StatefulWidget {
  static const String name = '/FIBCreationStepThreeScreen';

  @override
  _FIBCreationStepThreeState createState() => _FIBCreationStepThreeState();
}

class _FIBCreationStepThreeState extends State<FIBCreationStepThreeScreen> {
  core.FillInBlank fillInBlank;

  @override
  Widget build(BuildContext context) {
    if (fillInBlank == null)
      fillInBlank = ModalRoute.of(context).settings.arguments;

    double w30 = wp(30);
    double h62 = hp(62);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AppbarStepThree(),
            Container(
              margin: EdgeInsets.symmetric(vertical: h62, horizontal: w30),
              child: FlipCardWidget(
                frontText: "#Question 1",
                editable: false,
                front: <Widget>[
                  XFIBWidget(
                    componentData: fillInBlank,
                    index: 0,
                    mode: XComponentMode.Review,
                    enableHintWidget: false,
                  ),
                ],
                padding: EdgeInsets.symmetric(horizontal: hp(15)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: hp(44),
                color: XedColors.waterMelon,
                child: BottomActionBarWidget(
                  right: "Done",
                  left: "Previous",
                  next: true,
                  onTapLeft: _onTapLeft,
                  onTapRight: _onTapRight,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onTapLeft() {
    Navigator.of(context).pop();
  }

  void _onTapRight() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop(this.fillInBlank);
  }
}
