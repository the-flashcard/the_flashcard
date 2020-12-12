import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/resources/resources.dart';

class XProgressIndicator extends StatelessWidget {
  final double percen;

  const XProgressIndicator({Key key, this.percen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(width * 0.8);
    return AnimatedContainer(
      height: 1,
      duration: const Duration(milliseconds: 100),
      width: getWidth(context),
      color: XedColors.waterMelon,
    );
  }

  double getWidth(BuildContext context) {
    try {
      final double widthScreen = MediaQuery.of(context).size.width;
      final double width = widthScreen * percen;
      return width;
    } catch (ex) {
      core.Log.error(ex);
      return double.infinity;
    }
  }
}
