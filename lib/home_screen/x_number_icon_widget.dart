import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class XNumberIconWidget extends StatelessWidget {
  final void Function() onTap;

  final Widget icon;
  final int count;
  final double fontSize;

  XNumberIconWidget({
    @required this.icon,
    this.count = 0,
    this.onTap,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          child: icon,
          onTap: onTap != null ? () => XError.f0(onTap) : null,
        ),
        Container(
          margin: EdgeInsets.only(left: 3),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontFamily: 'HarmoniaSansProCyr',
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
              height: 1.4,
              color: XedColors.battleShipGrey,
            ),
          ),
        ),
      ],
    );
  }
}
