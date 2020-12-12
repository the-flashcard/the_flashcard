import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class IconBack extends StatelessWidget {
  final VoidCallback onTap;

  const IconBack({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        size: 30,
      ),
      color: XedColors.black,
      onPressed: onTap != null ? () => XError.f0(onTap) : null,
    );
  }
}
