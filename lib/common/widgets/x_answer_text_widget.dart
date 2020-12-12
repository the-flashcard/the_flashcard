import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';

class XAnswerTextWidget extends StatelessWidget {
  final core.Answer component;
  final bool isSelected;
  final bool isUserChoice;
  final XComponentMode mode;

  const XAnswerTextWidget({
    Key key,
    this.component,
    this.isSelected = false,
    this.isUserChoice = false,
    this.mode = XComponentMode.Review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return mode == XComponentMode.Result
        ? _buildResultComponent()
        : _buildNormalComponent();
  }

  Widget _buildResultComponent() {
    if (!isUserChoice && !component.correct) {
      return _buildNormalResultComponent();
    }
    Gradient gradient = _getGradientColor();

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: XedColors.white,
        gradient: gradient,
      ),
      child: _buildText(),
    );
  }

  Gradient _getGradientColor() {
    if (isUserChoice) {
      return LinearGradient(
        colors: [
          component.correct ? XedColors.weirdGreen : XedColors.cherryRedTwo,
          component.correct ? XedColors.algaeGreen : XedColors.cherryRed,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      return LinearGradient(
        colors: [
          component.correct ? XedColors.algaeGreen : XedColors.weirdGreen,
          component.correct ? XedColors.algaeGreen : XedColors.algaeGreen,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
  }

  Widget _buildText() {
    bool colorWhite =
        (mode == XComponentMode.Result && this.component.correct) ||
            isUserChoice ||
            isSelected;
    colorWhite = mode != XComponentMode.Editing && colorWhite;
    core.TextConfig textConfig = component.textConfig;
    TextStyle textStyle = textConfig?.toTextStyle() ?? TextStyle();
    textStyle =
        colorWhite ? textStyle.copyWith(color: XedColors.white) : textStyle;
    return Text(
      textConfig?.isUpperCase == true
          ? component.text.toUpperCase()
          : component.text,
      textAlign: textConfig?.toTextAlign() ?? TextAlign.left,
      style: textStyle,
    );
  }

  Widget _buildNormalComponent() {
    if (mode == XComponentMode.Review) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: XedColors.paleGrey,
          gradient: isSelected
              ? LinearGradient(
                  colors: [XedColors.waterMelon, XedColors.neonRed],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        child: _buildText(),
      );
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: XedColors.white,
        border: Border.all(
          color: isSelected ? XedColors.waterMelon : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            blurRadius: 6,
            spreadRadius: 0,
          )
        ],
      ),
      child: _buildText(),
    );
  }

  Widget _buildNormalResultComponent() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: XedColors.paleGrey,
      ),
      child: _buildText(),
    );
  }
}
