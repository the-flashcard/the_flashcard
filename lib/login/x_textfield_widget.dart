import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class XTextFieldWidget extends StatelessWidget {
  final Widget icon;
  final TextEditingController controller;
  final FocusNode node;
  final Color color;
  final Color cursorColor;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final TextInputType textInputType;
  final bool obscureText;
  final String hintText;
  final void Function(String) onSubmitted;
  final void Function(String) onChanged;
  const XTextFieldWidget({
    Key key,
    this.icon,
    this.controller,
    this.color,
    this.cursorColor = XedColors.waterMelon,
    this.textStyle,
    this.textInputType,
    this.obscureText,
    this.hintText,
    this.hintStyle,
    this.onSubmitted,
    this.onChanged,
    this.node,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color ?? Colors.transparent),
              borderRadius: BorderRadius.circular(27.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color ?? Colors.transparent),
              borderRadius: BorderRadius.circular(27.5),
            ),
            prefixIcon: icon,
            hintText: hintText ?? '',
            hintStyle: hintStyle,
          ),
          cursorColor: cursorColor,
          style: textStyle,
          keyboardType: textInputType,
          obscureText: obscureText ?? false,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          focusNode: node,
          controller: controller,
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: controller?.text?.trim()?.isNotEmpty ?? false
                ? _iconClearText(controller)
                : SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _iconClearText(TextEditingController controller) {
    return IconButton(
      alignment: Alignment.center,
      icon: Container(
        height: 24,
        width: 24,
        child: Center(
          child: Icon(
            Icons.close,
            color: XedColors.white255,
            size: 14,
          ),
        ),
        decoration: BoxDecoration(
          color: XedColors.duckEggBlue,
          shape: BoxShape.circle,
        ),
      ),
      onPressed: () => controller?.clear(),
    );
  }
}
