import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';

class GenerateCardScreen extends StatefulWidget {
  static String name = '/GenerateCardScreen';
  final ValueChanged<String> onGenerate;
  final String preScreenName;

  const GenerateCardScreen(this.preScreenName,
      {Key key, @required this.onGenerate})
      : super(key: key);

  @override
  _GenerateCardScreenState createState() => _GenerateCardScreenState();
}

class _GenerateCardScreenState extends XState<GenerateCardScreen> {
  final ScrollPhysics scrollPhysics = BouncingScrollPhysics();
  final TextEditingController textEditingController = TextEditingController();
  bool hasText = false;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XedColors.whiteTwoColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, size: 30, color: XedColors.black),
          onPressed: () => XError.f0(_onClosePressed),
        ),
        backgroundColor: XedColors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Generate Card', style: BoldTextStyle(18)),
      ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            color: XedColors.black.withOpacity(0.1),
            height: 1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  _buildGuide(),
                  Flexible(child: _buildTextInput(), fit: FlexFit.tight),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: hasText ? hp(44) : 0,
            child: _buildXedButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuide() {
    final String text = core.Config.getString("msg_generate");
    return XGuideWidget(desciption: text);
  }

  Widget _buildTextInput() {
    final String hintText = core.Config.getString("msg_fill_word");
    return TextField(
      controller: textEditingController,
      autofocus: true,
      scrollPhysics: scrollPhysics,
      textInputAction: TextInputAction.newline,
      minLines: 1,
      maxLines: null,
      decoration: InputDecoration(
        // contentPadding: const EdgeInsets.only(left: 5),
        hintText: hintText,
        border: InputBorder.none,
      ),
      style: RegularTextStyle(18).copyWith(color: XedColors.battleShipGrey),
      cursorColor: XedColors.waterMelon,
    );
  }

  Widget _buildXedButton() {
    return XedButtons.watermelonButton('GENERATE NOW!', 0, 14, _onGenerate);
  }

  void _onTextChanged() {
    if (textEditingController.text?.isEmpty == true && hasText) {
      setState(() {
        hasText = false;
      });
    } else if (textEditingController.text?.isNotEmpty == true && !hasText) {
      setState(() {
        hasText = true;
      });
    }
  }

  void _onGenerate() {
    closeUntil(this.widget.preScreenName);
    if (hasText && this.widget.onGenerate != null) {
      final String text = this.textEditingController.text;
      this.widget.onGenerate(text);
    }
  }

  void _onClosePressed() {
    closeUntil(this.widget.preScreenName);
  }
}

class XGuideWidget extends StatelessWidget {
  final String desciption;
  final TextStyle style;

  const XGuideWidget({Key key, this.desciption, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildGuide(desciption, style);
  }

  static Widget _buildGuide(String desciption, TextStyle style) {
    desciption ??= '';
    style ??= RegularTextStyle(14).copyWith(height: 1.4);

    return Container(
      decoration: BoxDecoration(
        color: XedColors.paleGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      height: hp(64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Icon(Icons.info, size: 20, color: XedColors.brownGrey),
            SizedBox(width: 10),
            Flexible(
              child: Text(desciption, style: style),
            )
          ],
        ),
      ),
    );
  }
}
