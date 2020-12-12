import 'package:flutter/material.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';

Future<void> xPopUp(
  BuildContext context, {
  String title,
  String description,
  String titleYes = 'Yes',
  String titleNo = '',
  VoidCallback onTapYes,
  VoidCallback onTapNo,
}) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext popupContext) {
        return AlertDialog(
          backgroundColor: XedColors.transparent,
          elevation: 0.0,
          contentPadding: EdgeInsets.all(0.0),
          content: Container(
            width: wp(345),
            height: hp(250),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: XedColors.white),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: wp(20), vertical: hp(20)),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: hp(24),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Tiempos",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(
                    height: hp(24),
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: RegularTextStyle(16)
                        .copyWith(color: XedColors.battleShipGrey),
                  ),
                  SizedBox(
                    height: hp(24),
                  ),
                  (titleNo.isEmpty || titleNo == null)
                      ? XedButtons.watermelonButton(
                          titleYes,
                          28,
                          14,
                          onTapYes,
                          width: wp(156),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              flex: 2,
                              child: XedButtons.whiteButton(
                                titleNo,
                                10,
                                14,
                                onTapNo,
                                withBorder: false,
                                textColor: XedColors.battleShipGrey,
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              flex: 3,
                              child: XedButtons.watermelonButton(
                                titleYes,
                                10,
                                14,
                                onTapYes,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(),
                ],
              ),
            ),
          ),
        );
      });
}
