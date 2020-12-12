import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/fib_screen/fib_creation_step_three_screen.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bottom_action_bar_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class FIBCreationStepTwoScreen extends StatefulWidget {
  static const String name = '/FIBCreationStepTwoScreen';

  @override
  _FIBCreationStepTwoState createState() => _FIBCreationStepTwoState();
}

class _FIBCreationStepTwoState extends State<FIBCreationStepTwoScreen> {
  final TextEditingController controller = TextEditingController();
  final answerControllers = <TextEditingController>[];
  final focusNodes = <FocusNode>[];
  final fibWigets = <Widget>[];
  core.FillInBlank fillInBlank;
  bool editEnable = true;
  bool _canNext = false;
  final listener = ValueNotifier<void>(() {});

  @override
  void dispose() {
    super.dispose();

    for (int i = 0; i < fillInBlank.correctAnswers.length; ++i) {
      focusNodes[i].dispose();
      answerControllers[i].dispose();
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bindParams();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AppbarStepTwo(),
            Padding(
              padding: EdgeInsets.only(
                left: wp(20),
                right: wp(20),
                top: hp(90),
                bottom: hp(44),
              ),
              child: ListView(
                children: fibWigets,
                key: Key(DriverKey.COMP_ANSWER),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                // height: hp(44),
                color: XedColors.waterMelon,
                child: BottomActionBarWidget(
                  left: "Previous",
                  right: "Next",
                  next: _canNext,
                  onTapLeft: _onTagLeft,
                  onTapRight: _onTapRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTextEditBottomBar() {
  //   return XToolboxEditTextWidget(
  //     defaultConfig: textConfig,
  //     callback: this,
  //     // focusNode: node,
  //     listener: listener,
  //     hasBlankComponent: true,
  //   );
  // }

  void _onTagLeft() {
    Navigator.of(context).pop();
  }

  void _onTapRight() {
    Navigator.of(context).pushNamed(
      FIBCreationStepThreeScreen.name,
      arguments: core.FillInBlank.fromQuestionAndAnswers(
        fillInBlank.question,
        _getAnswers(),
        textConfig: fillInBlank.textConfig,
      ),
    );
  }

  List<String> _getAnswers() {
    List<String> result = [];
    answerControllers.forEach((controller) => result.add(controller.text));
    return result;
  }

  bool _isEnableNext(List<TextEditingController> answerControllerList) {
    for (int i = 0; i < answerControllerList.length; ++i) {
      if (answerControllerList[i].text.isEmpty) return false;
    }

    return true;
  }

  Widget textFieldFIB(TextEditingController controller, int answerIndex) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: wp(5)),
      padding: EdgeInsets.symmetric(horizontal: wp(10)),
      decoration: BoxDecoration(
        color: XedColors.paleGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              "${answerIndex + 1}. ",
              style: ColorTextStyle(
                fontSize: 14.0,
                color: XedColors.battleShipGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: TextField(
              key: Key(DriverKey.COMP_ANSWER + "_$answerIndex"),
              controller: controller,
              autofocus: answerIndex == 0,
              focusNode: focusNodes[answerIndex],
              cursorColor: XedColors.waterMelon,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: core.Config.getString("msg_type_answer"),
                hintStyle: ColorTextStyle(
                  fontSize: 14.0,
                  color: XedColors.battleShipGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // style: fillInBlank.,
              textInputAction: _isTextFieldLast(answerIndex)
                  ? TextInputAction.done
                  : TextInputAction.next,
              onTap: () => XError.f0(() => editEnable = true),
              onChanged: _onChanged,
              onSubmitted: (String text) => XError.f0(() {
                if (_isTextFieldLast(answerIndex)) {
                  focusNodes[answerIndex].unfocus();
                  editEnable = false;
                } else {
                  FocusScope.of(context).requestFocus(
                    focusNodes[answerIndex + 1],
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  bool _isTextFieldLast(int number) {
    return number >= focusNodes.length - 1;
  }

  void _bindParams() {
    if (fillInBlank == null) {
      fillInBlank = ModalRoute.of(context).settings.arguments;
      // controller.value = controller.value.copyWith(text: fillInBlank.question);
      fibWigets.add(
        XTextWidget(
          componentData: core.Text.fromText(
            text: fillInBlank.question,
            textConfig: fillInBlank.textConfig,
          ),
        ),
      );
      fibWigets.add(SizedBox(height: hp(20)));
      for (var i = 0; i < fillInBlank.correctAnswers.length; i++) {
        focusNodes.add(FocusNode());
        answerControllers
            .add(TextEditingController()..text = fillInBlank.correctAnswers[i]);
        fibWigets.add(textFieldFIB(answerControllers[i], i));
      }
      // fillInBlank.correctAnswers?.forEach((correctAnswer) {
      //   focusNodes.add(FocusNode());
      //   answerControllers.add(TextEditingController()..text = correctAnswer);
      // });
      _canNext = _isEnableNext(answerControllers);
    }
  }

  void _onChanged(String value) {
    XError.f0(() => setState(() {
          _canNext = _isEnableNext(answerControllers);
        }));
  }
}
