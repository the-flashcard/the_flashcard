import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class SettingDropdownWidget extends StatelessWidget {
  final String title;
  final Widget icon;

  SettingDropdownWidget(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(hp(4)),
        border: Border.all(color: Color.fromRGBO(43, 43, 43, 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: wp(5)),
          icon,
          SizedBox(width: wp(3)),
          Text(
            title,
            style: SemiBoldTextStyle(12).copyWith(
              height: 1.4,
              color: XedColors.battleShipGrey,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: XedColors.battleShipGrey,
            size: wp(20),
          ),
        ],
      ),
    );
  }
}
