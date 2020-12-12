import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class XAddCardWizardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dimens.context = context;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'TAP ',
              textAlign: TextAlign.center,
              style: ColorTextStyle(
                fontSize: 12,
                color: XedColors.brownGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.add,
              color: XedColors.brownGrey,
              size: hp(12),
            ),
            Text(
              ' TO ADD THE FIRST',
              textAlign: TextAlign.center,
              style: ColorTextStyle(
                fontSize: 12,
                color: XedColors.brownGrey,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
        SizedBox(
          height: hp(5),
        ),
        Text(
          'CARD IN YOUR DECK',
          textAlign: TextAlign.center,
          style: ColorTextStyle(
            fontSize: 12,
            color: XedColors.brownGrey,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }
}
