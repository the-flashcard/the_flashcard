import 'package:flutter/material.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/deck_creation/fib_screen/circle_number_widget.dart';

class AppbarStepThree extends StatelessWidget {
  final String text;

  const AppbarStepThree({Key key, this.text = 'Completed'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: hp(50),
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: wp(20)),
                child: Row(
                  children: <Widget>[
                    CircleNumberWidget(
                      number: 0,
                      color: XedColors.waterMelon,
                    ),
                    SizedBox(width: wp(10)),
                    CircleNumberWidget(
                      number: 0,
                      color: XedColors.waterMelon,
                    ),
                    SizedBox(width: wp(10)),
                    CircleNumberWidget(
                      number: 3,
                      color: XedColors.waterMelon,
                    ),
                    SizedBox(width: wp(10)),
                    Text(
                      this.text,
                      style: SemiBoldTextStyle(16),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: hp(2),
                child: Stack(
                  children: <Widget>[
                    Container(
                        width: double.infinity,
                        color: Color.fromRGBO(244, 244, 244, 1)),
                    Container(
                      color: XedColors.waterMelon,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
