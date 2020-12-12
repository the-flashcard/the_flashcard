import 'package:flutter/widgets.dart';

enum Direction { _vertical, _horizontal }

double wp(double designSize) =>
    Dimens._actualSize(Direction._vertical, designSize);

double hp(double designSize) =>
    Dimens._actualSize(Direction._horizontal, designSize);

class Dimens {
  //Text size
  static const largeTextSize = 18.0;
  static const normalTextSize = 14.0;
  static const headerTextSize = 22.0;

  //design screen size
  static const _screenDesignWidth = 375;
  static const _screenDesignHeight = 667;
  static double screenWidth;
  static double screenHeight;

  Dimens._();

  //Non-null
  static BuildContext context;

  static double _actualSize(Direction direction, double designSize) {
    if (screenWidth == null || screenHeight == null) {
      var queryData = MediaQuery.of(context);
      if (queryData != null && !queryData.size.isEmpty) {
        screenWidth = queryData.size.width;
        screenHeight = queryData.size.height;
      }
    }

    switch (direction) {
      case Direction._vertical:
        final ratio = _screenDesignWidth / designSize;
        return screenWidth != null ? screenWidth / ratio : designSize;
      default:
        final ratio = _screenDesignHeight / designSize;
        return screenHeight != null ? screenHeight / ratio : designSize;
    }
  }
}
