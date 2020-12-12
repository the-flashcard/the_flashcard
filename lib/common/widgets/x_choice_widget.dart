import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/widgets/x_answer_multi_widget.dart';
import 'package:the_flashcard/common/widgets/x_answer_text_widget.dart';
import 'package:the_flashcard/xerror.dart';

typedef AnswerCallBack = void Function(core.Answer, bool);

class XAnswerChoiceWidget extends StatefulWidget {
  final AnswerCallBack onTap;
  final core.Answer component;
  final bool isRadioButton;
  final bool isOnlyText;
  final XComponentMode mode;
  final bool isUserChoice;
  final bool isSelected;
  final ValueNotifier<void> listenerUnchooseAnswer;
  final String valueKey;

  const XAnswerChoiceWidget({
    Key key,
    this.onTap,
    @required this.component,
    this.isRadioButton = true,
    this.isOnlyText = false,
    this.mode = XComponentMode.Review,
    this.isUserChoice = false,
    this.listenerUnchooseAnswer,
    this.isSelected,
    this.valueKey = '',
  }) : super(key: key);

  @override
  _XAnswerChoiceWidgetState createState() => _XAnswerChoiceWidgetState();
}

class _XAnswerChoiceWidgetState extends State<XAnswerChoiceWidget> {
  Set<core.Component> components = Set<core.Component>();
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == XComponentMode.Review && widget.isRadioButton) {
      widget.listenerUnchooseAnswer?.removeListener(_unchooseAnswer);
      widget.listenerUnchooseAnswer?.addListener(_unchooseAnswer);
    }

    return GestureDetector(
      key: Key(widget?.valueKey ?? ''),
      child: widget.isOnlyText ? _buildOnlyText() : _buildMultiComponent(),
      onTap: () => XError.f0(() {
        if (widget.mode == XComponentMode.Review ||
            widget.mode == XComponentMode.Editing) {
          setState(() {
            isSelected = !isSelected;
          });
          if (widget.onTap != null)
            this.widget.onTap(widget.component, isSelected);
        }
      }),
    );
  }

  Widget _buildOnlyText() {
    double spacer = hp(10);
    double spacer1 = hp(6);

    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        widget.isRadioButton ? _radioButtonChoice() : _checkBoxButton(),
        SizedBox(width: spacer),
        Expanded(
          child: XAnswerTextWidget(
            component: widget.component,
            isSelected: isSelected,
            mode: widget.mode,
            isUserChoice: widget.isUserChoice,
          ),
        ),
        SizedBox(width: spacer1),
      ],
    );
  }

  Widget _buildMultiComponent() {
    return Stack(
      children: <Widget>[
        XAnswerMultiWidget(
          component: widget.component,
          isSelected: isSelected,
          mode: widget.mode,
        ),
        widget.isRadioButton ? _radioButtonChoice() : _checkBoxButton()
      ],
    );
  }

  Widget _radioButtonChoice() {
    double hp30 = hp(30);
    return widget.mode == XComponentMode.Result
        ? _buildRadioResultButton(hp30)
        : _buildRadioNormalButton(hp30);
  }

  Widget _checkBoxButton() {
    double hp30 = hp(30);
    return widget.mode == XComponentMode.Result
        ? _buildCheckBoxResultButton(hp30)
        : _buildCheckBoxNormalButton(hp30);
  }

  Widget _buildCheckBoxResultButton(double hp30) {
    Color color = _getButtonColor();
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 5, right: 8),
      child: Container(
        width: hp30,
        height: hp30,
        child: Icon(
          widget.isUserChoice || widget.component.correct
              ? Icons.check_box
              : Icons.check_box_outline_blank,
          size: hp30 - (widget.isOnlyText ? 0 : 5),
          color: color,
        ),
      ),
    );
  }

  Widget _buildCheckBoxNormalButton(double hp30) {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 5, right: 8),
      child: Container(
        width: hp30,
        height: hp30,
        child: Icon(
          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
          size: hp30 - (widget.isOnlyText ? 0 : 5),
          color: isSelected ? XedColors.waterMelon : XedColors.duckEggBlue,
        ),
      ),
    );
  }

  Widget _buildRadioNormalButton(double hp30) {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 5, right: 8),
      child: Container(
        width: hp30,
        height: hp30,
        child: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          size: hp30 - (widget.isOnlyText ? 0 : 5),
          color: isSelected ? XedColors.waterMelon : XedColors.duckEggBlue,
        ),
      ),
    );
  }

  Widget _buildRadioResultButton(double hp30) {
    Color color = _getButtonColor();

    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 5, right: 8),
      child: Container(
        width: hp30,
        height: hp30,
        child: Icon(
          widget.isUserChoice || widget.component.correct
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          size: hp30 - (widget.isOnlyText ? 0 : 5),
          color: color,
        ),
      ),
    );
  }

  Color _getButtonColor() {
    if (widget.isUserChoice) {
      return widget.component.correct
          ? XedColors.algaeGreen
          : XedColors.cherryRed;
    } else {
      return widget.component.correct
          ? XedColors.algaeGreen
          : XedColors.duckEggBlue;
    }
  }

  void _unchooseAnswer() {
    if (isSelected && mounted)
      setState(() {
        isSelected = false;
      });
  }
}
