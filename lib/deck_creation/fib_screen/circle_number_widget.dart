import 'package:flutter/material.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';

class CircleNumberWidget extends StatelessWidget {
  final int number;
  final double size;
  final Color color;

  const CircleNumberWidget({
    Key key,
    @required this.number,
    this.size = 26,
    this.color = XedColors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size),
          color: color,
          boxShadow: color == XedColors.whiteTextColor
              ? [
                  BoxShadow(
                    blurRadius: 6,
                    spreadRadius: 0,
                    color: Color.fromARGB(25, 0, 0, 0),
                  )
                ]
              : []),
      child: Center(
        child: Container(
            padding: number != 0 ? EdgeInsets.only(top: 4.0, left: 2.0) : null,
            child: number != 0
                ? Text(number.toString(),
                    style: color == XedColors.whiteTextColor
                        ? SemiBoldTextStyle(16)
                        : ColorTextStyle(
                            fontSize: 16,
                            color: XedColors.whiteTextColor,
                            fontWeight: FontWeight.w600,
                          ))
                : Icon(
                    Icons.check,
                    color: XedColors.whiteTextColor,
                    size: 20,
                  )),
      ),
    );
  }
}
