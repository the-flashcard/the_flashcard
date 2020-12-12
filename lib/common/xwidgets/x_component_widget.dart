import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;

enum XComponentMode { Preview, Review, Result, Editing }

abstract class XComponentWidget<T extends core.Component>
    extends StatelessWidget {
  final XComponentMode mode;
  final int index;
  final T componentData;

  @mustCallSuper
  XComponentWidget(
    this.componentData,
    this.index, {
    Key key,
    this.mode = XComponentMode.Review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildComponentWidget(context);
  }

  Widget buildComponentWidget(BuildContext context);
}
