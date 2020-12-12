import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;

class ViewText extends StatelessWidget {
  final core.Text component;

  ViewText(this.component);

  @override
  Widget build(BuildContext context) {
    return component.text != null || component.text.isNotEmpty
        ? Container(
            child: textComponent(
              data: component.text,
              textConfig: component.textConfig,
            ),
          )
        : SizedBox();
  }
}

Widget textComponent({@required String data, core.TextConfig textConfig}) {
  return Text(
    textConfig?.isUpperCase == true ? data.toUpperCase() : data,
    textAlign: textConfig?.toTextAlign(),
    style: textConfig?.toTextStyle(),
  );
}
