import 'package:flutter/material.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';

class TextDescriptionWidget extends StatelessWidget {
  final bool canShow;
  final String title;
  final String description;

  TextDescriptionWidget(
      {@required this.canShow, this.title = "", this.description = ""});

  @override
  Widget build(BuildContext context) {
    return canShow
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: RegularTextStyle(16)
                      .copyWith(color: XedColors.whiteTextColor),
                ),
                Text(
                  description,
                  style: SemiBoldTextStyle(55)
                      .copyWith(color: XedColors.whiteTextColor),
                ),
              ],
            ),
          )
        : SizedBox();
  }
}
