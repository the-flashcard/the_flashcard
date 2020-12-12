import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/fib_screen/circle_number_widget.dart';
import 'package:the_flashcard/deck_creation/x_progress_indicator.dart';

class AppbarStepWidget extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String text;
  final int currentStep;
  const AppbarStepWidget(
    this.text, {
    Key key,
    this.height = 50,
    this.currentStep = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          currentStep == 1 ? _appBarStepOneWidget(text ?? '') : SizedBox(),
          currentStep == 2 ? _appBarStepTwoWidget(text ?? '') : SizedBox(),
          currentStep == 3 ? _appBarStepThreeWidget(text ?? '') : SizedBox(),
          Align(
            alignment: Alignment.bottomLeft,
            child: XProgressIndicator(percen: currentStep / 3),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  Widget _appBarStepOneWidget(String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            CircleNumberWidget(
              number: 1,
              color: XedColors.waterMelon,
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                this.text,
                style: SemiBoldTextStyle(16),
              ),
            ),
            Spacer(),
            CircleNumberWidget(
              number: 2,
            ),
            SizedBox(width: 10),
            CircleNumberWidget(
              number: 3,
            )
          ],
        ),
      ),
    );
  }

  Widget _appBarStepTwoWidget(String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            CircleNumberWidget(
              number: 0,
              color: XedColors.waterMelon,
            ),
            SizedBox(width: 10),
            CircleNumberWidget(
              number: 2,
              color: XedColors.waterMelon,
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                this.text,
                style: SemiBoldTextStyle(16),
              ),
            ),
            Spacer(),
            CircleNumberWidget(
              number: 3,
            )
          ],
        ),
      ),
    );
  }

  Widget _appBarStepThreeWidget(String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            CircleNumberWidget(
              number: 0,
              color: XedColors.waterMelon,
            ),
            SizedBox(width: 10),
            CircleNumberWidget(
              number: 0,
              color: XedColors.waterMelon,
            ),
            SizedBox(width: 10),
            CircleNumberWidget(
              number: 3,
              color: XedColors.waterMelon,
            ),
            SizedBox(width: 10),
            Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                this.text,
                style: SemiBoldTextStyle(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
