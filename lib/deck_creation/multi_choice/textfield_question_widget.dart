import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class TextFieldQuestionWidget extends StatefulWidget {
  final String hintText;
  final TextStyle hintStyle;
  final TextStyle style;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final TextEditingController controller;
  final bool enable;
  final FocusNode focusNode;
  final TextAlign textAlign;
  final String keyValue;

  TextFieldQuestionWidget({
    Key key,
    this.hintText,
    this.hintStyle,
    @required this.style,
    @required this.onChanged,
    this.controller,
    @required this.onTap,
    this.enable = true,
    @required this.focusNode,
    @required this.textAlign,
    this.keyValue = '',
  }) : super(key: key);

  @override
  _TextFieldQuestionWidgetState createState() =>
      _TextFieldQuestionWidgetState();
}

class _TextFieldQuestionWidgetState extends State<TextFieldQuestionWidget> {
  final bool test = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      // autofocus: false,
      key: Key(widget?.keyValue ?? ''),
      maxLines: null,
      style: widget.style,
      enabled: widget.enable,
      controller: widget.controller,
      textInputAction: TextInputAction.newline,
      cursorColor: XedColors.waterMelon,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        border: InputBorder.none,
      ),
      onChanged: widget.onChanged != null
          ? (text) => XError.f1<String>(widget.onChanged, text)
          : null,
      onTap: widget.onTap != null ? () => XError.f0(widget.onTap) : null,
      textAlign: widget.textAlign,
    );
  }
}
