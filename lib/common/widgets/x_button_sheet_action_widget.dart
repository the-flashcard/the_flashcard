import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/xerror.dart';

class XButtonSheetActionWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final VoidCallback onTap;

  const XButtonSheetActionWidget({Key key, this.text, this.style, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheetAction(
      child: Text(
        text,
        style: style ??
            RegularTextStyle(20).copyWith(
              color: XedColors.battleShipGrey,
              height: 1.4,
            ),
      ),
      onPressed: onTap != null ? () => XError.f0(onTap) : null,
    );
  }
}
