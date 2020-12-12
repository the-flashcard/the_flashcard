import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class LearningWithoutDeckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Không có gì để học",
            style: SemiBoldTextStyle(22),
          ),
          Text(
            "Người eo tôi hum nay không có gì để học",
            style: RegularTextStyle(14)
                .copyWith(height: 1.6, color: XedColors.battleShipGrey),
          )
        ],
      ),
    );
  }
}
