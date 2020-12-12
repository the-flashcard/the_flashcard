import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/gradient_color.dart';
import 'package:the_flashcard/common/xwidgets/x_image_component.dart';

class XCardSideWidget extends StatelessWidget {
  final Color grey = Color.fromRGBO(123, 124, 125, 1);
  final Color watermelon = Color.fromRGBO(253, 68, 104, 1);

  final XComponentMode mode;
  final String title;
  final core.Container cardContainer;
  final Key key;
  final List<String> userFIBAnswers;
  final Set<int> userMCAnswers;
  final FIBAnswerCallback onFIBAnswerChanged;
  final OnAnswersChanged onMCAnswerChanged;

  XCardSideWidget({
    @required this.mode,
    @required this.title,
    @required this.cardContainer,
    this.key,
    this.userFIBAnswers = const <String>[],
    this.userMCAnswers = const <int>{},
    this.onFIBAnswerChanged,
    this.onMCAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    double marginHorizontal = 12;
    double marginTop = hp(25);
    double marginBottom = hp(20);
    double width27 = wp(105);

    final gradient =
        cardContainer?.toGradient() ?? core.XGradientColor.init().toGradient();
    final gradient2 = getGradientFromGradient(gradient);

    var margin = EdgeInsets.fromLTRB(
      marginHorizontal,
      marginTop,
      marginHorizontal,
      marginBottom,
    );
    var margin2 = margin.copyWith(
      left: margin.left + margin.top / 2,
      top: hp(10),
    );
    return Stack(
      children: <Widget>[
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
            width: wp(275),
            height: hp(367),
            alignment: cardContainer?.toAlignment(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: cardContainer?.toGradient(),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(wp(10), hp(10), wp(10), hp(10)),
              child: SingleChildScrollView(
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.max,
                  children: _buildListWidget(),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: hp(30),
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: gradient2,
          ),
          child: Center(
            child: AutoSizeText(
              this.title ?? '',
              textAlign: TextAlign.justify,
              style: BoldTextStyle(12).copyWith(
                letterSpacing: 0.43,
                color: gradient.colors.length > 1
                    ? XedColors.white
                    : XedColors.brownGrey,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildListWidget() {
    final widgets = <Widget>[];
    var components = cardContainer.components ?? [];
    components.where((component) {
      switch (mode) {
        case XComponentMode.Editing:
          return true;
        default:
          if (component is core.Image)
            return component.hasUrl;
          else if (component is core.Audio)
            return component.hasUrl;
          else if (component is core.Video)
            return component.hasUrl;
          else
            return true;
          break;
      }
    }).fold(0, (index, component) {
      widgets.add(Padding(
        padding: EdgeInsets.symmetric(vertical: hp(10)),
        child: _buildComponentWidget(index, component),
      ));
      return (index + 1);
    });
    return widgets;
  }

  Widget _buildComponentWidget(int index, core.Component component) {
    if (component is core.Text) {
      return XTextWidget(
        componentData: component,
        index: index,
      );
    } else if (component is core.Image) {
      return XImageComponent(
        componentData: component,
        index: index,
      );
    } else if (component is core.Audio) {
      return XAudioPlayerWidget(
        component,
        index,
        mode: mode,
      );
    } else if (component is core.Video) {
      return XVideoPlayerWidget(
        component,
        index,
      );
    } else if (component is core.MultiChoice) {
      return XMultiChoiceWidget(
        component,
        mode: mode,
        userAnswers: userMCAnswers,
        onAnswersChanged: onMCAnswerChanged,
      );
    } else if (component is core.MultiSelect) {
      return XMultiChoiceWidget(
        component,
        mode: mode,
        userAnswers: userMCAnswers,
        onAnswersChanged: onMCAnswerChanged,
      );
    } else if (component is core.FillInBlank) {
      return XFIBWidget(
        mode: mode,
        componentData: component,
        index: index,
        userAnswers: userFIBAnswers,
        answerCallback: onFIBAnswerChanged,
        enableHintWidget: false,
      );
    } else if (component is core.Dictionary) {
      return XDictionaryWidget(component, index);
    } else {
      return SizedBox();
    }
  }
}
