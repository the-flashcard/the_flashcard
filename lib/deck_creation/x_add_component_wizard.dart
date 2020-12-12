import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/gradient_color.dart';
import 'package:the_flashcard/environment/constants.dart' as cons;

class XAddComponentWizardWidget extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final Gradient gradient2;
  final _hasGradient;

  XAddComponentWizardWidget(this.title, this.gradient)
      : _hasGradient = gradient.colors.length > 1,
        gradient2 = getGradientFromGradient(gradient);

  @override
  Widget build(BuildContext context) {
    double marginHorizontal = 12;
    double marginTop = hp(25);
    double marginBottom = hp(20);
    double width = wp(275);
    double height = hp(504);
    double width27 = wp(105);
    double partPaddingTop = marginTop / 2;

    var margin = EdgeInsets.fromLTRB(
      marginHorizontal,
      marginTop,
      marginHorizontal,
      marginBottom,
    );
    EdgeInsets margin2 = margin.copyWith(
      left: margin.left + margin.top / 2,
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
            borderRadius: BorderRadius.circular(25),
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
              gradient: this.gradient,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
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
            gradient: this.gradient2,
          ),
          child: Center(
            child: AutoSizeText(
              title ?? '',
              textAlign: TextAlign.justify,
              style: cons.textStyleQuestion.copyWith(
                color: _hasGradient ? XedColors.white : XedColors.brownGrey,
              ),
            ),
          ), // padding: const EdgeInsets.all(0)
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
                  color: _hasGradient ? XedColors.white : XedColors.brownGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.create,
                color: _hasGradient ? XedColors.white : XedColors.brownGrey,
                size: hp(12),
              ),
              Text(
                ' TO ADD THE FIRST',
                textAlign: TextAlign.center,
                style: ColorTextStyle(
                  fontSize: 12,
                  color: _hasGradient ? XedColors.white : XedColors.brownGrey,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          SizedBox(
            height: hp(5),
          ),
          Text(
            'COMPONENT IN YOUR CARD',
            textAlign: TextAlign.start,
            style: ColorTextStyle(
              fontSize: 12,
              color: _hasGradient ? XedColors.white : XedColors.brownGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
