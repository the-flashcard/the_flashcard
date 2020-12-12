import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';

class XConfirmPopup extends StatelessWidget {
  final String title;
  final String description;

  XConfirmPopup({@required this.title, @required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hp(250),
      color: XedColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(title, style: BoldTextStyle(18)),
          Text(
            description,
            style: RegularTextStyle(14),
          ),
          _buildButton('Yes', () {
            Navigator.of(context).pop(true);
          }),
          // SizedBox(height: 10),
          _buildButton('Cancel', () {
            Navigator.of(context).pop(false);
          }, isCancel: true),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap,
      {bool isCancel = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          style: SemiBoldTextStyle(16).copyWith(
            color: isCancel ? XedColors.whiteTextColor : XedColors.black,
          ),
        ),
        onPressed: onTap != null ? () => XError.f0(onTap) : null,
        fillColor: isCancel ? XedColors.waterMelon : XedColors.duckEggBlue,
      ),
    );
  }
}
