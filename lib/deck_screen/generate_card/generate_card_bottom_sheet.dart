import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/resources/xed_sheets.dart';

class GenerateCardBottomSheet extends StatelessWidget {
  final VoidCallback onManualPressed;
  final VoidCallback onGeneratePressed;
  final String preScreenName;

  const GenerateCardBottomSheet(
    this.preScreenName, {
    Key key,
    this.onManualPressed,
    this.onGeneratePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return XedSheets.bottomSheet(
      context,
      'Select an option:',
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 27),
              XedButtons.textWithArrowButton(
                'Manual',
                onTap: () => _onManualPressed(context),
              ),
              SizedBox(height: 27),
              XedButtons.textWithArrowButton(
                'Auto Generate',
                onTap: () => _onGeneratePressed(context),
              ),
              SizedBox(height: 27),
            ],
          ),
        ),
      ),
    );
  }

  void _onManualPressed(BuildContext context) {
    core.PopUtils.popUntil(context, this.preScreenName);
    if (this.onManualPressed != null) {
      this.onManualPressed();
    }
  }

  void _onGeneratePressed(BuildContext context) {
    core.PopUtils.popUntil(context, this.preScreenName);
    if (this.onGeneratePressed != null) {
      this.onGeneratePressed();
    }
  }
}
