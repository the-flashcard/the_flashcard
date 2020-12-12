import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/xwidgets/x_component_widget.dart';

class XTextWidget extends XComponentWidget<core.Text> {
  XTextWidget({
    @required core.Text componentData,
    int index = 0,
    XComponentMode mode,
  }) : super(componentData, index, mode: mode);

  @override
  Widget buildComponentWidget(BuildContext context) {
    return _textComponent(
      data: componentData?.text ?? '',
      textConfig: componentData.textConfig,
    );
  }

  Widget _textComponent({@required String data, core.TextConfig textConfig}) {
    return Container(
      width: double.infinity,
      child: Text(
        textConfig?.isUpperCase ?? false == true ? data.toUpperCase() : data,
        textAlign: textConfig?.toTextAlign() ?? TextAlign.left,
        style: textConfig?.toTextStyle(),
      ),
    );
  }
}
