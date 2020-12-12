import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/environment/driver_key.dart';

abstract class XState<T extends StatefulWidget> extends State<T> {
  static void showSnakeBar(
    BuildContext context,
    String content,
    Color backgroundColor,
  ) {
    try {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(content),
        backgroundColor: backgroundColor,
      ));
    } catch (ex) {
      core.Log.error(ex);
    }
  }

  void showErrorSnakeBar(String content, {BuildContext context}) {
    showSnakeBar(context ?? this.context, content, Colors.red);
  }

  void showSuccessSnakeBar(String content, {BuildContext context}) {
    showSnakeBar(context ?? this.context, content, Colors.green);
  }

  void closeScreen(String screenName, {BuildContext context}) {
    var ctx = context ?? this.context;
    core.PopUtils.popUntil(ctx, screenName);
    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
  }

  void closeUntil(String screenName, {BuildContext context}) {
    core.PopUtils.popUntil(context ?? this.context, screenName);
  }

  void closeUntilRootScreen({BuildContext context}) {
    core.PopUtils.popUntil(context ?? this.context, "/");
  }

  Future<T> navigateToScreen<T>({
    @required Widget screen,
    String name,
    bool isPopToRoot = false,
  }) {
    if (isPopToRoot) {
      closeUntilRootScreen();
    }
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => screen,
        settings: name != null ? RouteSettings(name: name) : null,
      ),
    );
  }

  Future<T> globalNavigateToScreen<T>({@required Widget screen, String name}) {
    return DriverKey.navigatorGlobalKey.currentState.push<T>(
      MaterialPageRoute(
        builder: (_) => screen,
        settings: name != null ? RouteSettings(name: name) : null,
      ),
    );
  }

  void globalPopToRoot() {
    return DriverKey.navigatorGlobalKey.currentState
        .popUntil(ModalRoute.withName('/'));
  }

  void unfocus() {
    if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
  }

  void reRender({VoidCallback fn}) {
    try {
      if (mounted) {
        setState(fn ?? () {});
      }
    } catch (e) {
      //Todo: Ignore this exception.
    }
  }
}
