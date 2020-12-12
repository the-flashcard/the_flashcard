import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';

class IconTextWiget extends StatelessWidget {
  final String text;

  final IconData icon;

  final bool enable;

  final VoidCallback onTap;

  final TextStyle style;

  final bool reverse;

  // final bool reverse;

  const IconTextWiget({
    Key key,
    @required this.text,
    @required this.icon,
    this.reverse = false,
    this.enable = true,
    this.onTap,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = this.style ??
        SemiBoldTextStyle(18).copyWith(
            color: enable ? Colors.white : Colors.white.withOpacity(0.2),
            height: 1.4);
    Widget _textWidget = _getText(text, style);
    Widget _iconWidget = _getIcon(icon, enable);
    return FlatButton.icon(
      onPressed: enable && onTap != null ? () => XError.f0(onTap) : null,
      icon: reverse ? _textWidget : _iconWidget,
      label: reverse ? _iconWidget : _textWidget,
    );
  }

  Widget _getIcon(IconData icon, bool enable) {
    return Icon(
      icon,
      size: 30,
      color: enable ? Colors.white : Colors.white.withOpacity(0.2),
    );
  }

  Widget _getText(String text, TextStyle style) {
    return Text(
      text,
      style: style,
    );
  }
}
