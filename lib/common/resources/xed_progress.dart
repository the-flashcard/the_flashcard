import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class XedProgress {
  XedProgress._();

  static Widget indicator({Color color = XedColors.waterMelon, double value}) {
    return SizedBox(
      height: hp(20),
      width: hp(20),
      child: CircularProgressIndicator(
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 1,
      ),
    );
  }
}
