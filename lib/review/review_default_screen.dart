import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/resources/xed_colors.dart';

import '../common/resources/resources.dart';

class ReviewDefaultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wp(40)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(Assets.imgReviewDefault),
          SizedBox(
            height: hp(30),
          ),
          Text(
            "Let’s do it!",
            style: BoldTextStyle(22),
          ),
          SizedBox(
            height: hp(5),
          ),
          Text(
            core.Config.getString("msg_due_date_intro"),
            textAlign: TextAlign.center,
            style: RegularTextStyle(14).copyWith(
              color: XedColors.battleShipGrey,
              height: 1.4,
            ),
          )
        ],
      ),
    );
  }
}
