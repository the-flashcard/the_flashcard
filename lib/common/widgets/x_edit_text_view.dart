import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';

class XEditTextView extends StatefulWidget {
  final TextEditingController _controller;
  final void Function(String text) onChanged;
  final void Function(String text) onSubmitted;
  final String _label;
  final String errorText;
  final String _hint;
  final bool _isPassword;
  final String valueKey;

  XEditTextView(
    this._controller,
    this._label,
    this._hint,
    this._isPassword, {
    this.valueKey,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  _XEditTextViewState createState() => _XEditTextViewState(hint: _hint ?? '');
}

class _XEditTextViewState extends State<XEditTextView> {
  final FocusNode focusNode = FocusNode();

  String hint;

  _XEditTextViewState({this.hint = ''});

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      setState(() {
        hint = focusNode.hasFocus ? '' : widget._hint;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Color.fromARGB(255, 220, 221, 221),
      ),
      child: Align(
        alignment: Alignment.center,
        child: InputDecorator(
          decoration: InputDecoration(
              labelText: widget._label,
              errorText: widget.errorText,
              labelStyle: TextStyle(
                fontFamily: 'HarmoniaSansProCyr',
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                color: Color.fromARGB(255, 43, 43, 43),
              ),
              errorStyle: TextStyle(fontSize: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              )),
          child: TextField(
            key: Key(widget.valueKey ?? ''),
            autocorrect: false,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            controller: widget._controller,
            obscureText: widget._isPassword,
            cursorColor: XedColors.waterMelon,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: XedColors.brownGrey),
              contentPadding: EdgeInsets.only(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
              ),
              errorStyle: TextStyle(fontSize: 8),
              border: InputBorder.none,
            ),
            focusNode: focusNode,
          ),
        ),
      ),
    );
  }
}
