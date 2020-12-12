import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';

class DeleteImageButtonWidget extends StatelessWidget {
  final VoidCallback onPressDelete;

  DeleteImageButtonWidget({@required this.onPressDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.all(8.0),
        height: hp(26),
        width: wp(26),
        child: FloatingActionButton(
          heroTag: null,
          child: Icon(
            Icons.close,
            color: Colors.white,
          ),
          backgroundColor: XedColors.black,
          onPressed:
              onPressDelete != null ? () => XError.f0(onPressDelete) : null,
        ),
      ),
    );
  }
}
