import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class ReportOption extends StatefulWidget {
  final String text;
  final List<bool> optionChoosen;
  final int index;
  final Function setStateParent;

  ReportOption(this.text, this.optionChoosen, this.index, this.setStateParent);

  @override
  _ReportOptionState createState() => _ReportOptionState();
}

class _ReportOptionState extends State<ReportOption> {
  String text;
  List<bool> optionChoosen;
  int index;

  @override
  void initState() {
    super.initState();
    text = widget.text;
    optionChoosen = widget.optionChoosen;
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: wp(5), right: wp(5), bottom: wp(10)),
      child: InkWell(
        onTap: () => XError.f0(() {
          setState(() {
            optionChoosen[index] = !optionChoosen[index];
            widget.setStateParent();
          });
        }),
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 12, 15, 10),
          decoration: BoxDecoration(
            color: optionChoosen[index]
                ? XedColors.waterMelon
                : XedColors.duckEggBlue,
            borderRadius: BorderRadius.circular(hp(18)),
          ),
          child: Text(
            text,
            style: SemiBoldTextStyle(14).copyWith(
              fontSize: 14,
              color: optionChoosen[index] ? XedColors.white : XedColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
