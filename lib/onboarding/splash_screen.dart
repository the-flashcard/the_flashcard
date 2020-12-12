import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/assets.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';

class SplashScreen extends StatefulWidget {
  static const name = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Dimens.context = context;

    return Scaffold(
      backgroundColor: XedColors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SvgPicture.asset(
              Assets.icLogoPortrait,
              height: 150,
              width: 150,
            ),
          ),
          SizedBox(height: 15.0),
          XedProgress.indicator(),
        ],
      ),
    );
  }
}
