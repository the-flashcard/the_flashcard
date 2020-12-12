import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/widgets/appbar_step_one_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/fib_screen/fib_creation_step_two_screen.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bottom_action_bar_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class FIBCreationStepOneScreen extends StatefulWidget {
  static const String name = '/deckFIBCreationStepOne';
  final core.FillInBlank model;

  FIBCreationStepOneScreen.create({Key key})
      : model = null,
        super(key: key);

  FIBCreationStepOneScreen.edit({Key key, this.model}) : super(key: key);

  @override
  _FIBCreationStepOneState createState() => _FIBCreationStepOneState();

  static String deleteBlank(String text, int pos) {
    var blanks = core.FIBUtils.getBlanks(text)
        .where((e) => pos >= e.key && pos <= e.value);
    String result = text;
    if (blanks.isNotEmpty)
      result = text.replaceRange(blanks.first.key, blanks.first.value, " ");
    return result;
  }
}

class _FIBCreationStepOneState extends XState<FIBCreationStepOneScreen>
    with OnTextToolBoxCallBack {
  TextEditingController controller = TextEditingController();
  final FocusNode node = FocusNode();

  // Key key = UniqueKey();
  Key key = Key(DriverKey.COMP_QUESTION);
  core.FillInBlank fillInBlank;
  String oldText = '';
  bool editEnable = true;
  bool isEditing = false;
  final listener = ValueNotifier<void>(() {});
  core.TextConfig textConfig;

  @override
  void initState() {
    fillInBlank = widget.model ??
        core.FillInBlank.fromQuestionAndAnswers("", <String>[],
            textConfig: textConfig);
    controller.value = controller.value.copyWith(text: fillInBlank.question);
    textConfig = widget.model == null
        ? (core.TextConfig()
          ..textAlign = 0
          ..lineHeight = 1.4)
        : core.TextConfig.fromJson(widget.model.textConfig.toJson());

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    node?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            AppbarStepOne(),
            Padding(
              padding: EdgeInsets.only(
                left: wp(20),
                right: wp(20),
                top: hp(91),
                bottom: hp(44),
              ),
              child: TextField(
                key: key,
                autofocus: true,
                focusNode: node,
                decoration: InputDecoration(border: InputBorder.none),
                maxLines: null,
                cursorColor: XedColors.waterMelon,
                controller: controller,
                style: textConfig.toTextStyle(),
                textAlign: textConfig.toTextAlign(),
                onTap: () => XError.f0(() {
                  listener.value = () {};
                  if (editEnable == false)
                    setState(() {
                      editEnable = true;
                    });
                }),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                // height: hp(44),
                color: editEnable ? Colors.black : XedColors.waterMelon,
                child: editEnable
                    ? _buildTextEditBottomBar()
                    : BottomActionBarWidget(
                        left: "Cancel",
                        right: "Next",
                        next: controller.text.isNotEmpty,
                        onTapRight: _onTapRight,
                        onTapLeft: _onTapLeft,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextEditBottomBar() {
    return XToolboxEditTextWidget(
      defaultConfig: textConfig,
      callback: this,
      focusNode: node,
      listenerHideEditPanel: listener,
      hasBlankComponent: true,
    );
  }

  void _onTapRight() {
    Navigator.of(context).pushNamed(
      FIBCreationStepTwoScreen.name,
      arguments: core.FillInBlank.fromQuestionAndAnswers(
        controller.text,
        _initAnswerList(),
        textConfig: textConfig,
      ),
    );
  }

  void _onTapLeft() {
    closeScreen(FIBCreationStepOneScreen.name);
  }

  // void _onQuestionTextChange(String text) {
  //   if (!isEditing) {
  //     isEditing = true;
  //     if (_isDeleteEvent(text)) {
  //       int deletePostion = controller.selection.start;
  //       String textAfterDelete =
  //           FIBCreationStepOneScreen.deleteBlank(oldText, deletePostion);
  //       print("Before Delete: $text \n After Delete: $textAfterDelete");
  //       // controller.value = controller.value.copyWith(text: textAfterDelete);
  //       controller.text = textAfterDelete;
  //     }
  //     isEditing = false;
  //   }
  //   oldText = controller.text;
  // }
  // bool _isDeleteEvent(String text) {
  //   return text.length < oldText.length;
  // }

  List<String> _initAnswerList() {
    List<String> result;
    int blankCount = core.FIBUtils.getBlanks(controller.text).length;

    if (widget.model != null) {
      int len = widget.model.correctAnswers.length;
      if (blankCount > 0)
        result = List.generate(
            blankCount, (i) => i < len ? widget.model.correctAnswers[i] : '');
      else {
        result = [len > 0 ? widget.model.correctAnswers.first : ''];
      }
    } else {
      if (blankCount > 0) {
        result = List.generate(blankCount, (i) => "");
      } else
        result = [''];
    }
    return result;
  }

  @override
  void onConfigApply(core.TextConfig config, bool isCancel) {
    this.textConfig = config;
    editEnable = false;
    unfocus();
    reRender();
  }

  @override
  void onConfigChanged(core.TextConfig config,
      {bool textAlignChanged = false}) {
    this.textConfig = config;
    if (textAlignChanged) key = UniqueKey();
    reRender();
  }

  @override
  void onShowKeyboard(core.TextConfig config, bool showKeyboard) {}

  @override
  void onTapAddBlank() {
    _addBlank(controller);
  }

  void _addBlank(TextEditingController controller) {
    int pos = controller.selection.start;
    int end = controller.selection.end;
    String textAfterAdd = controller.text.substring(0, pos) +
        core.FIBUtils.createBlank(0) +
        controller.text.substring(end);

    textAfterAdd = core.FIBUtils.format(textAfterAdd);
    controller.text = textAfterAdd;
    controller.selection = TextSelection.collapsed(offset: textAfterAdd.length);
  }
}
