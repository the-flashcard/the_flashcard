import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common.dart';

class DeckThumbnailDefaultWiget extends StatelessWidget {
  final BoxDecoration boxDecoration;
  final double heightIcon;

  DeckThumbnailDefaultWiget({
    Key key,
    @required this.boxDecoration,
    this.heightIcon = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecoration,
      child: Center(
        child: SvgPicture.asset(
          Assets.icDefaultDeck,
          color: XedColors.deckDefaultColor,
          height: hp(heightIcon),
        ),
      ),
    );
  }
}
