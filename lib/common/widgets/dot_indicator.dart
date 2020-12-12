import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class DotIndicator extends StatelessWidget {
  final int totalDots;
  final int indexSpecialDot;
  final Color colorDot;
  final Color colorSpecialDot;
  final List _dotList = <Widget>[];

  DotIndicator({
    Key key,
    @required this.totalDots,
    @required this.indexSpecialDot,
    this.colorDot = XedColors.duckEggBlue,
    this.colorSpecialDot = XedColors.waterMelon,
  })  : assert(totalDots != null && totalDots > 0),
        assert(indexSpecialDot < totalDots && indexSpecialDot != null,
            "indexSpecialDot must be smaller than totalDots and not null"),
        assert(colorDot != null || colorSpecialDot != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _dotList.clear();
    for (int i = 0; i < totalDots; i++) {
      if (i == indexSpecialDot) {
        _dotList.add(_specialDot());
      } else {
        _dotList.add(_dot());
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _dotList,
    );
  }

  Widget _dot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: colorDot),
        width: 10,
        height: 10,
      ),
    );
  }

  Widget _specialDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorSpecialDot,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        width: 20,
        height: 10,
      ),
    );
  }
}
