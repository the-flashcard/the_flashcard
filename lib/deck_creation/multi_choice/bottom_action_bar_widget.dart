import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/multi_choice/icon_text_widget.dart';

typedef ShowButton = bool Function();

class BottomActionBarWidget extends StatelessWidget {
  final String left;
  final String right;
  final bool pre;
  final bool next;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  BottomActionBarWidget({
    this.left = 'Cancel',
    this.right = 'Next',
    this.pre = true,
    this.next = false,
    this.onTapLeft,
    this.onTapRight,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconTextWiget(
          icon: Icons.chevron_left,
          text: left,
          onTap: onTapLeft != null ? () => XError.f0(onTapLeft) : null,
          enable: pre,
        ),
        IconTextWiget(
          icon: Icons.chevron_right,
          text: right,
          reverse: true,
          enable: next,
          onTap: onTapRight != null ? () => XError.f0(onTapRight) : null,
        )
      ],
    );
  }
}
