import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/xwidgets/x_component_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_text_widget.dart';
import 'package:the_flashcard/common/xwidgets/x_toolbox_answer_text_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/xerror.dart';

typedef FIBAnswerCallback = void Function(int, bool, List<String>);

class XFIBWidget extends XComponentWidget<core.FillInBlank> {
  final FIBAnswerCallback answerCallback;
  final List<String> userAnswers;
  final bool enableHintWidget;

  XFIBWidget({
    Key key,
    @required core.FillInBlank componentData,
    @required int index,
    XComponentMode mode,
    this.userAnswers = const <String>[],
    this.answerCallback,
    this.enableHintWidget = true,
  }) : super(componentData, index, mode: mode, key: key);

  @override
  Widget buildComponentWidget(BuildContext context) {
    return _FIBWidget(
      index: index,
      mode: mode,
      componentData: componentData,
      userAnswers: userAnswers,
      answerCallback: answerCallback,
      enableHintWidget: enableHintWidget,
    );
  }
}

class _FIBWidget extends StatefulWidget {
  final XComponentMode mode;
  final int index;
  final core.FillInBlank componentData;
  final FIBAnswerCallback answerCallback;
  final List<String> userAnswers;
  final bool enableHintWidget;

  _FIBWidget({
    @required this.index,
    @required this.mode,
    @required this.componentData,
    this.userAnswers = const <String>[],
    this.answerCallback,
    this.enableHintWidget,
  });

  @override
  __FIBWidgetState createState() => __FIBWidgetState();
}

class __FIBWidgetState extends State<_FIBWidget>
    implements OnAnswerTextCallBack {
  final answerControllers = <TextEditingController>[];
  final answerFocusNode = <FocusNode>[];
  int location = 0;
  bool _enableEdit = false;
  final listener = ValueNotifier<void>(() {});
  final widgets = <Widget>[];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.componentData.correctAnswers.length; i++) {
      answerControllers.add(TextEditingController());
      answerFocusNode.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.componentData.correctAnswers.length; i++) {
      answerControllers[i].dispose();
      answerFocusNode[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widgets
      ..clear()
      ..add(
        Padding(
          padding: EdgeInsets.only(
            bottom: hp(5),
          ),
          child: XTextWidget(
            componentData: core.Text.fromText(
              text: widget.mode == XComponentMode.Result
                  ? core.FIBUtils.formatWithAnswers(
                      widget.componentData.question,
                      widget.componentData.correctAnswers,
                    )
                  : core.FIBUtils.format(widget.componentData.question),
              textConfig: widget.componentData.textConfig,
            ),
            index: 0,
          ),
        ),
      );
    for (int pos = 0; pos < widget.componentData.correctAnswers.length; pos++) {
      widgets.add(
        _answerTextField(answerControllers[pos], answerFocusNode[pos], pos),
      );
    }
    if (widget.mode == XComponentMode.Review)
      widgets.add(_enableEdit ? SizedBox(height: hp(115)) : SizedBox());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _answerTextField(
      TextEditingController controller, FocusNode focusNode, int indexAnswer) {
    switch (widget.mode) {
      case XComponentMode.Result:
        String userAnswer = (widget.userAnswers != null &&
                indexAnswer < widget.userAnswers.length)
            ? widget.userAnswers[indexAnswer]
            : null;
        bool isCorrect =
            widget.componentData.validateAnswer(indexAnswer, userAnswer);

        controller.text = userAnswer ?? '';

        return Container(
          margin: EdgeInsets.symmetric(vertical: wp(5)),
          padding: EdgeInsets.symmetric(horizontal: wp(10)),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "${indexAnswer + 1}. ",
                  style: ColorTextStyle(
                    fontSize: 14.0,
                    color: XedColors.battleShipGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: isCorrect
                        ? LinearGradient(
                            colors: [
                              XedColors.weirdGreen,
                              XedColors.algaeGreen
                            ],
                            begin: Alignment(0, 0),
                            end: Alignment(1, 1),
                          )
                        : LinearGradient(
                            colors: [
                              XedColors.cherryRedTwo,
                              XedColors.cherryRed
                            ],
                            begin: Alignment(0, 0),
                            end: Alignment(1, 1),
                          ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wp(16)),
                    child: TextField(
                      controller: controller,
                      autofocus: false,
                      cursorColor: XedColors.waterMelon,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: ColorTextStyle(
                          fontSize: 14.0,
                          color: XedColors.battleShipGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      readOnly: true,
                      style: SemiBoldTextStyle(14.0)
                          .copyWith(color: XedColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case XComponentMode.Review:
        return Container(
          margin: EdgeInsets.symmetric(vertical: wp(5)),
          padding: EdgeInsets.symmetric(horizontal: wp(10)),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "${indexAnswer + 1}. ",
                  style: ColorTextStyle(
                    fontSize: 14.0,
                    color: XedColors.battleShipGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: XedColors.paleGrey,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: wp(16)),
                    child: TextField(
                      key: Key(DriverKey.COMP_ANSWER + "_$indexAnswer"),
                      controller: controller,
                      focusNode: focusNode,
                      // autofocus: indexAnswer == 0,
                      cursorColor: XedColors.waterMelon,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: ColorTextStyle(
                          fontSize: 14.0,
                          color: XedColors.battleShipGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      readOnly: false,
                      onChanged: (text) => XError.f0(
                        () => _onAnswerChanged(indexAnswer, text),
                      ),
                      onTap: () => XError.f1<int>(_onTapTextField, indexAnswer),
                      onSubmitted: (text) => XError.f0(
                        _onSubmitted(indexAnswer),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          margin: EdgeInsets.symmetric(vertical: wp(5)),
          padding: EdgeInsets.symmetric(horizontal: wp(10)),
          decoration: BoxDecoration(
            color: XedColors.paleGrey,
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  "${indexAnswer + 1}. ",
                  style: ColorTextStyle(
                    fontSize: 14.0,
                    color: XedColors.battleShipGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: TextField(
                  controller: controller,
                  autofocus: false,
                  cursorColor: XedColors.waterMelon,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: ColorTextStyle(
                      fontSize: 14.0,
                      color: XedColors.battleShipGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
        );
    }
  }

  void _onAnswerChanged(int indexAnswer, String text) {
    var userAnswers = answerControllers
        .map<String>((answerController) => answerController.text.trim())
        .toList();

    var validAnswerCount =
        userAnswers.where((text) => text != null && text.isNotEmpty).length;
    if (widget.answerCallback != null) {
      widget.answerCallback(
          widget.index,
          widget.componentData.correctAnswers.length == validAnswerCount,
          userAnswers);
    }
  }

  void _onTapTextField(int index) {
    listener.value = () {};
    if (!_enableEdit)
      setState(() {
        _enableEdit = true;
      });
    location = index;
    _openToolbox();
  }

  void _openToolbox() {
    if (_enableEdit && widget.enableHintWidget) {
      Scaffold.of(context)
          .showBottomSheet((_) {
            return XToolboxAnswerTextWidget(
              callBack: this,
              focusNodeList: answerFocusNode,
              controllerList: answerControllers,
              answerList: widget.componentData.correctAnswers,
              location: location,
              // canNext: _canNext,
              listenerHideEditPanel: listener,
            );
          })
          .closed
          .whenComplete(() {
            if (mounted) {
              _enableEdit = false;
            }
          });
    }
  }

  void _closeToolbox() {
    setState(() {
      _enableEdit = false;
      if (widget.enableHintWidget) {
        widgets.removeLast();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void onPressDelete() {
    if (answerControllers[location].text != null &&
        answerControllers[location].text.isNotEmpty) {
      answerControllers[location].text = answerControllers[location]
          .text
          .substring(0, answerControllers[location].text.length - 1);
    }
  }

  @override
  void onPressRefresh() {
    answerControllers[location].clear();
  }

  @override
  void onSelectedElement(String element) {
    answerControllers[location].text += element;
    _onAnswerChanged(location, answerControllers[location].text);
  }

  @override
  void onShowKeyboard(bool showKeyboard) {}

  @override
  void onSubmitted() {
    if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
    _closeToolbox();
  }

  _onSubmitted(int indexAnswer) {
    if (indexAnswer < answerControllers.length - 1) {
      FocusScope.of(context).requestFocus(answerFocusNode[indexAnswer + 1]);
    } else {
      _closeToolbox();
    }
  }
}
