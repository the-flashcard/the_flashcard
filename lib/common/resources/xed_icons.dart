import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:the_flashcard/common/common.dart';

class XedIcon {
  XedIcon._();

  static ImageIcon iconFlip(double size) {
    return ImageIcon(
      AssetImage('assets/images/icFlipCardGray.png'),
      size: 45,
      color: Colors.white,
    );
  }

  static Widget iconStar(double size,
      {Color backGroundColor = XedColors.blue, Color color = XedColors.white}) {
    return Container(
      width: size ?? 20,
      height: size ?? 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backGroundColor,
      ),
      child: Icon(
        Icons.star,
        color: color,
        size: 20,
      ),
    );
  }

  static Widget iconDefaultAvatar(double height, double width) {
    height ??= hp(25);
    width ??= wp(25);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          shape: BoxShape.circle,
          color: XedColors.carnation),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
