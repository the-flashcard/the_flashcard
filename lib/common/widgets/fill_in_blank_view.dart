import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/widgets/text_view.dart';

class ViewFillInBlank extends StatefulWidget {
  final core.FillInBlank fillInBlank;
  final bool previewMode;

  ViewFillInBlank(this.fillInBlank, {this.previewMode = false});

  @override
  _ViewFillInBlankState createState() => _ViewFillInBlankState();

  static String formatFillInBlank(String question) {
    var elements = question.split("___");
    var result = question;
    if (elements.length > 1) {
      result = "";
      for (int i = 0; i < elements.length - 1; ++i) {
        var fib = "___ (${i + 1})";
        result += elements[i] + fib;
      }
      result += elements.last;
    }
    return result;
  }

  static String removeNumberInFIB(String question, int number) {
    var elements = question.split("___ ($number)");
    var result = question;
    if (elements.length > 1) {
      result = "";
      for (int i = 0; i < elements.length - 1; ++i) {
        var fib = "___";
        result += elements[i] + fib;
      }
      result += elements.last;
    }
    return result;
  }
}

class _ViewFillInBlankState extends State<ViewFillInBlank> {
  final answerControllerList = <TextEditingController>[];
  final widgetFIBList = <Widget>[];
  final focusNodeList = <FocusNode>[];
  int numOfFill;
  int fib;

  @override
  void initState() {
    super.initState();
    if (widget.fillInBlank.question != null ||
        widget.fillInBlank.question.isNotEmpty) {
      fib = core.FIBUtils.getBlanks(widget.fillInBlank.question).length;
      numOfFill = widget.fillInBlank.correctAnswers.length;
      core.Log.debug(widget.fillInBlank.question);
      widgetFIBList.add(Padding(
        padding: EdgeInsets.only(
          bottom: hp(20),
        ),
        child: ViewText(core.Text()..text = widget.fillInBlank.question),
      ));
      answerControllerList.addAll(
        List.generate(
          numOfFill,
          (i) => TextEditingController(),
        ),
      );
    }
    // if (fib != 0) {
    //   for (int i = 0; i < numOfFill; i++) {
    //     widgetFIBList.add(textFieldWithNumber(answerControllerList[i], i));
    //   }
    // } else {
    //   widgetFIBList.add(textFieldWithoutNumber(answerControllerList[fib]));
    // }
    for (int i = 0; i < numOfFill; i++) {
      widgetFIBList.add(textFieldWithNumber(answerControllerList[i], i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgetFIBList,
    );
  }

  Widget textFieldWithNumber(
      TextEditingController controller, int indexAnswer) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: wp(5)),
      padding: EdgeInsets.symmetric(horizontal: wp(10)),
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
              autofocus: indexAnswer == 0 && !widget.previewMode,
              cursorColor: XedColors.waterMelon,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: !widget.previewMode
                    ? core.Config.getString("msg_type_answer")
                    : '',
                hintStyle: ColorTextStyle(
                  fontSize: 14.0,
                  color: XedColors.battleShipGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              readOnly: widget.previewMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget textFieldWithoutNumber(TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: wp(5)),
      padding: EdgeInsets.symmetric(horizontal: wp(10)),
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: TextField(
        controller: controller,
        autofocus: !widget.previewMode,
        cursorColor: XedColors.waterMelon,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: !widget.previewMode ? 'Fill sub content here…' : '',
          hintStyle: ColorTextStyle(
            fontSize: 14.0,
            color: XedColors.battleShipGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
        readOnly: widget.previewMode,
      ),
    );
  }
}
