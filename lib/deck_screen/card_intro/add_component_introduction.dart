import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/environment/constants.dart' as cons;

class AddComponentIntroduction extends StatelessWidget {
  final String title;

  const AddComponentIntroduction({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double marginHorizontal = 20;
    double marginTop = hp(25);
    double width = wp(355);
    double height = hp(504);
    double width27 = wp(125);
    double partPaddingTop = marginTop / 2;

    var margin = EdgeInsets.only(
      left: marginHorizontal,
      top: marginTop,
      right: marginHorizontal,
    );
    EdgeInsets margin2 = margin.copyWith(
      left: width27,
      top: margin.top / 2 - 1.2,
    );

    return Stack(
      children: [
        Container(
          height: hp(30),
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        SizedBox(
          height: double.infinity,
          child: Container(
            margin: margin,
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: XedColors.white255,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, partPaddingTop + 5, 0, 0),
              child: _buildAddComponentGuide(),
            ),
          ),
        ),
        Container(
          height: hp(30),
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: XedColors.white255,
          ),
          child: Center(
            child: AutoSizeText(
              title ?? '',
              textAlign: TextAlign.justify,
              style: cons.textStyleQuestion.copyWith(
                color: XedColors.brownGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddComponentGuide() {
    double width = wp(275);
    double height = hp(423);
    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'TAP ',
                textAlign: TextAlign.center,
                style: ColorTextStyle(
                  fontSize: 12,
                  color: XedColors.brownGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.create,
                color: XedColors.brownGrey,
                size: hp(12),
              ),
              Text(
                ' TO CREATE THE',
                textAlign: TextAlign.center,
                style: ColorTextStyle(
                  fontSize: 12,
                  color: XedColors.brownGrey,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          SizedBox(
            height: hp(5),
          ),
          Text(
            'INTRODUCTION FOR DECK',
            textAlign: TextAlign.start,
            style: ColorTextStyle(
              fontSize: 12,
              color: XedColors.brownGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
