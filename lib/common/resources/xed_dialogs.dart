import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';

class XedDialogs {
  XedDialogs._();

  static Widget outdatedDialog() {
    return Center(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: wp(8), top: hp(70)),
            child: Container(
              width: wp(325),
              height: hp(245),
              alignment: Alignment.center,
              color: XedColors.redTextColor,
            ),
          ),
          Container(
            //color: Colors.blue,
            child: SvgPicture.asset(Assets.imgForceUpdate),
          ),
          Padding(
            padding: EdgeInsets.only(left: wp(8), top: hp(70)),
            child: Container(
              width: wp(325),
              height: hp(245),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Material(
                    color: XedColors.transparent,
                    child: Text(
                      'Hi There!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Tiempos",
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Material(
                    color: XedColors.transparent,
                    child: Text(
                      'Our new version is now available for download.',
                      style: RegularTextStyle(16)
                          .copyWith(color: XedColors.battleShipGrey),
                    ),
                  ),
                  Material(
                    color: XedColors.transparent,
                    child: XedButtons.watermelonButton(
                      'UPDATE NOW',
                      hp(28),
                      14,
                      () {},
                      width: wp(180),
                      height: hp(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
