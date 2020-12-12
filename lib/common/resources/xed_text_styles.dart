import 'package:flutter/material.dart';

import 'dimens.dart';
import 'xed_colors.dart';
import 'xed_font_family.dart';

class RegularTextStyle extends TextStyle {
  RegularTextStyle(double fontSize)
      : super(
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}

class LightTextStyle extends TextStyle {
  LightTextStyle(double fontSize)
      : super(
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontWeight: FontWeight.w400,
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}

class MediumTextStyle extends TextStyle {
  MediumTextStyle(double fontSize)
      : super(
          fontWeight: FontWeight.w500,
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.tiempos,
        );
}

class SemiBoldTextStyle extends TextStyle {
  SemiBoldTextStyle(double fontSize)
      : super(
          fontWeight: FontWeight.w600,
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}

class BoldTextStyle extends TextStyle {
  BoldTextStyle(double fontSize)
      : super(
          fontWeight: FontWeight.bold,
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}

class BoldPhoneticTextStyle extends TextStyle {
  BoldPhoneticTextStyle(double fontSize)
      : super(
          fontWeight: FontWeight.bold,
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.doulosSIL,
        );
}

class BlackTextStyle extends TextStyle {
  BlackTextStyle(double fontSize)
      : super(
          fontWeight: FontWeight.w900,
          color: XedColors.black,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}

class ColorTextStyle extends TextStyle {
  ColorTextStyle(
      {@required double fontSize,
      @required Color color,
      @required FontWeight fontWeight})
      : super(
          fontWeight: fontWeight,
          color: color,
          fontSize: hp(fontSize),
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}

class XDefaultTextStyle extends TextStyle {
  XDefaultTextStyle()
      : super(
          fontSize: 14,
          height: 1.4,
          color: XedColors.black,
          fontFamily: FontFamily.harmoniaSansProCyr,
        );
}
