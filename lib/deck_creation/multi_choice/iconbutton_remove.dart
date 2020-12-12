import 'package:flutter/material.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';

class IconButtonRemove extends StatelessWidget {
  final double size;
  final double iconSize;

  const IconButtonRemove({Key key, this.size = 20, this.iconSize = 14})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        color: XedColors.blackTextColor.withOpacity(0.9),
      ),
      child: Icon(Icons.close, size: iconSize, color: Colors.white),
    );
  }
}
