import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/review/progress/review_bottom_bar_widget.dart';

class ReviewInteractionQuizWidget extends StatefulWidget {
  final Function onNoPressed;
  final Function onYesPressed;
  final bool isAnswered;
  final Function onNext;
  final bool isLastPage;
  final int dayLeft;

  ReviewInteractionQuizWidget(this.isAnswered, this.isLastPage,
      {this.onNoPressed, this.onYesPressed, this.onNext, this.dayLeft});

  @override
  _ReviewInteractionQuizWidgetState createState() =>
      _ReviewInteractionQuizWidgetState();
}

class _ReviewInteractionQuizWidgetState
    extends State<ReviewInteractionQuizWidget> {
  Widget yesNoInteraction() {
    return Container(
      height: hp(83),
      width: wp(375),
      decoration: BoxDecoration(
        color: XedColors.white,
        border: Border(
          top: BorderSide(
            width: 1,
            color: Color.fromRGBO(18, 18, 18, 0.1),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: hp(15)),
          Text(
            'Do you remember?',
            style: ColorTextStyle(
              color: XedColors.battleShipGrey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: widget.onNoPressed != null
                      ? () => XError.f0(widget.onNoPressed)
                      : null,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        MaterialCommunityIcons.circle_outline,
                        size: 24,
                        color: XedColors.black,
                      ),
                      SizedBox(width: wp(8)),
                      Text(
                        'No, I don\'t',
                        style: SemiBoldTextStyle(18),
                        key: ValueKey(DriverKey.TEXT_NO),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onYesPressed != null
                      ? () => XError.f0(widget.onYesPressed)
                      : null,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        MaterialCommunityIcons.heart,
                        size: 24,
                        color: XedColors.waterMelon,
                      ),
                      SizedBox(width: wp(8)),
                      Text(
                        'Yes, I do',
                        style: SemiBoldTextStyle(18),
                        key: ValueKey(DriverKey.TEXT_YES),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget daysLeftInteraction() {
    return ReviewBottomBarWidget(
      onTapNext: widget.onNext,
      daysLeft: widget.dayLeft,
      isLastPage: widget.isLastPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: widget.isAnswered ? daysLeftInteraction() : yesNoInteraction(),
    );
  }
}
