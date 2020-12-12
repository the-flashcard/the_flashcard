import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_image_component.dart';

class XReviewCardSideWidget extends StatelessWidget {
  final Color grey = Color.fromRGBO(123, 124, 125, 1);
  final Color watermelon = Color.fromRGBO(253, 68, 104, 1);

  final XComponentMode mode;
  final String title;
  final core.Container cardContainer;
  final Key key;

  final Map<int, Set<int>> userMCAnswers;
  final Map<int, List<String>> userFIBAnswers;

  final FIBAnswerCallback onFIBAnswerChanged;
  final OnAnswersChanged onMCAnswerChanged;

  XReviewCardSideWidget({
    @required this.mode,
    @required this.title,
    @required this.cardContainer,
    this.key,
    this.userFIBAnswers = const <int, List<String>>{},
    this.userMCAnswers = const <int, Set<int>>{},
    this.onFIBAnswerChanged,
    this.onMCAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: cardContainer?.toAlignment(),
      decoration: BoxDecoration(
        gradient: cardContainer?.toGradient(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wp(10)),
        child: SingleChildScrollView(
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.max,
            children: _buildListWidget(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildListWidget() {
    final widgets = <Widget>[];
    var components = cardContainer?.components ?? [];
    var isAutoPlay = components.whereType<core.Audio>().length == 1;
    core.Log.debug('isAutoPlay: $isAutoPlay');
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
        child: _buildComponentWidget(index, component, isAutoPlay),
      ));
      return (index + 1);
    });
    return widgets;
  }

  Widget _buildComponentWidget(
      int index, core.Component component, isAutoPlay) {
    switch (component.runtimeType) {
      case core.Text:
        return XTextWidget(
          componentData: component,
          index: index,
        );
      case core.Image:
        return XImageComponent(
          componentData: component,
          index: index,
        );
      case core.Audio:
        return XAudioPlayerWidget(component, index,
            mode: mode, isAutoPlay: isAutoPlay);
      case core.Video:
        return XVideoPlayerWidget(component, index);
      case core.MultiChoice:
        return XMultiChoiceWidget(
          component,
          index: index,
          mode: mode,
          userAnswers: userMCAnswers[index] ?? <int>{},
          onAnswersChanged: onMCAnswerChanged,
        );
      case core.MultiSelect:
        return XMultiChoiceWidget(
          component,
          index: index,
          mode: mode,
          userAnswers: userMCAnswers[index] ?? <int>{},
          onAnswersChanged: onMCAnswerChanged,
        );
      case core.FillInBlank:
        return XFIBWidget(
          mode: mode,
          componentData: component,
          index: index,
          userAnswers: userFIBAnswers[index] ?? <String>[],
          answerCallback: onFIBAnswerChanged,
        );
      case core.Dictionary:
        return XDictionaryWidget(component, index);
      default:
        return SizedBox();
    }
  }
}
