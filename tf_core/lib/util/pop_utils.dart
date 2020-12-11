import 'package:flutter/widgets.dart';
class PopUtils {
  static void popUntil(BuildContext context, String nameOfScreen) {
    Navigator.popUntil(context, ModalRoute.withName(nameOfScreen));
  }
}
