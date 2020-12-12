import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class BottomSheetItemWidget extends StatelessWidget {
  final String title;
  final Widget icon;
  final Function onSelected;

  BottomSheetItemWidget(this.title, this.icon, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: <Widget>[
          SizedBox(height: hp(13)),
          Row(
            children: <Widget>[
              SizedBox(width: wp(15)),
              icon,
              SizedBox(width: wp(10)),
              Text(
                title,
                style: SemiBoldTextStyle(16).copyWith(height: 1.4),
              ),
            ],
          ),
          SizedBox(height: hp(13)),
        ],
      ),
      onTap: () => XError.f0(() => onSelected),
    );
  }
}
