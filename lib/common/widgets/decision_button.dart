import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class DecisionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String content;
  final Color bgColor;
  final Color textColor;

  DecisionButton(
      {@required this.onPressed,
      @required this.content,
      this.bgColor = XedColors.waterMelon,
      this.textColor = Colors.white})
      : assert(onPressed != null),
        assert(content != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: wp(40)),
      height: hp(56),
      width: wp(335),
      child: MaterialButton(
          onPressed: onPressed != null ? () => XError.f0(onPressed) : null,
          child: Text(
            content,
            style: ColorTextStyle(
                fontSize: Dimens.largeTextSize,
                color: textColor,
                fontWeight: FontWeight.bold),
          )),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: bgColor,
      ),
    );
  }
}
