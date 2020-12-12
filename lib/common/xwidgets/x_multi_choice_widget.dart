import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/widgets/x_choice_widget.dart';
import 'package:the_flashcard/common/xwidgets/xwidgets.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/xerror.dart';

typedef OnAnswersChanged = void Function(int, Set<int>);

class XMultiChoiceWidget extends XComponentWidget<core.BaseMC> {
  final Set<int> userAnswers;
  final OnAnswersChanged onAnswersChanged;

  XMultiChoiceWidget(
    core.BaseMC componentData, {
    Key key,
    int index = 0,
    XComponentMode mode = XComponentMode.Review,
    this.userAnswers = const <int>{},
    this.onAnswersChanged,
  }) : super(componentData, index, key: key, mode: mode);

  @override
  Widget buildComponentWidget(BuildContext context) {
    return _XMultiChoiceWidget(
      index: index,
      componentData: componentData,
      mode: mode,
      onAnswersChanged: onAnswersChanged,
      userAnswers: userAnswers,
    );
  }
}

class _XMultiChoiceWidget extends StatefulWidget {
  final core.BaseMC componentData;
  final int index;
  final XComponentMode mode;
  final OnAnswersChanged onAnswersChanged;
  final Set<int> userAnswers;

  _XMultiChoiceWidget(
      {Key key,
      @required this.index,
      this.componentData,
      this.mode,
      this.onAnswersChanged,
      this.userAnswers})
      : super(key: key);

  @override
  __XMultiChoiceWidgetState createState() => __XMultiChoiceWidgetState(
        componentData,
        mode,
        onAnswersChanged,
        userAnswers,
      );
}

class __XMultiChoiceWidgetState extends State<_XMultiChoiceWidget> {
  final listener = <ValueNotifier<void>>[];
  bool _isOnlyText;
  bool _isRadioButton;
  final Set<int> _currentAnswers = Set<int>();
  final core.BaseMC componentData;
  final XComponentMode mode;
  final OnAnswersChanged onAnswersChanged;
  final Set<int> userAnswers;

  __XMultiChoiceWidgetState(
    this.componentData,
    this.mode,
    this.onAnswersChanged,
    this.userAnswers,
  );

  @override
  Widget build(BuildContext context) {
    _isOnlyText = componentData.isOnlyText();
    _isRadioButton = _checkIsRadioButton(componentData.answers);

    bool onlyOneAnswer = _isRadioButton && widget.mode == XComponentMode.Review;

    if (onlyOneAnswer && listener.isEmpty) {
      listener.addAll(
        List.generate(
          widget.componentData.answers.length,
          (_) => ValueNotifier(() {}),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: hp(5)),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildQuestion(),
          SizedBox(height: 15),
          _buildAnswer(context, onlyOneAnswer),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    core.TextConfig textConfig = componentData.textConfig;
    return Text(
      textConfig?.isUpperCase == true
          ? componentData.question.toUpperCase()
          : componentData.question,
      textAlign: textConfig?.toTextAlign() ?? TextAlign.left,
      style: textConfig?.toTextStyle(),
    );
  }

  Widget _buildAnswer(BuildContext context, bool onlyOneAnswer) {
    return _isOnlyText
        ? _buildTextAnswer(_isRadioButton, onlyOneAnswer)
        : _buildMultiComponentAnswer(_isRadioButton, onlyOneAnswer);
  }

  Widget _buildMultiComponentAnswer(bool isRadioButton, bool onlyOneAnswer) {
    double heightSpacer = hp(5);
    return StaggeredGridView.countBuilder(
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: heightSpacer,
      mainAxisSpacing: heightSpacer,
      itemCount: componentData.answers.length,
      itemBuilder: (_, i) => XAnswerChoiceWidget(
        valueKey: DriverKey.MULTI_RIGHT_ANSWER + "_$i",
        component: componentData.answers[i],
        onTap: (answer, isSelected) =>
            XError.f2<int, bool>(_onAnswerChanged, i, isSelected),
        isRadioButton: isRadioButton,
        mode: mode,
        listenerUnchooseAnswer: onlyOneAnswer ? listener[i] : null,
        isUserChoice: _getIsChoice(i),
      ),
      staggeredTileBuilder: (_) => StaggeredTile.fit(2),
    );
  }

  Widget _buildTextAnswer(bool isRadioButton, bool onlyOneAnswer) {
    double heightSpacer = hp(10);
    SizedBox spacer = SizedBox(height: heightSpacer);

    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      itemCount: componentData.answers.length,
      shrinkWrap: true,
      itemBuilder: (_, int i) {
        return XAnswerChoiceWidget(
          valueKey: DriverKey.MULTI_RIGHT_ANSWER + "_$i",
          component: componentData.answers[i],
          onTap: (answer, isSelected) =>
              XError.f2<int, bool>(_onAnswerChanged, i, isSelected),
          isRadioButton: isRadioButton,
          isOnlyText: true,
          listenerUnchooseAnswer: onlyOneAnswer ? listener[i] : null,
          mode: mode,
          isUserChoice: _getIsChoice(i),
        );
      },
      separatorBuilder: (_, int index) => spacer,
    );
  }

  void _onAnswerChanged(int index, bool isSelected) {
    if (mode == XComponentMode.Review) {
      if (_isRadioButton) {
        _limitButtonChoice(index, isSelected);
      } else {
        if (_currentAnswers.contains(index)) {
          _currentAnswers.remove(index);
        } else {
          _currentAnswers.add(index);
        }
      }

      if (onAnswersChanged != null) {
        onAnswersChanged(
          widget.index,
          _currentAnswers.isNotEmpty
              ? (Set<int>()..addAll(_currentAnswers))
              : Set<int>(),
        );
      }
    }
  }

  bool _getIsChoice(int index) {
    return userAnswers.contains(index);
  }

  static bool _checkIsRadioButton(List<core.Answer> answers) {
    int numAnswer = 0;
    for (var answer in answers) {
      if (answer.correct) ++numAnswer;
      if (numAnswer >= 2) return false;
    }
    return true;
  }

  void _limitButtonChoice(int index, bool isSelected) {
    if (isSelected) {
      //Remove anthor item selected
      if (_currentAnswers.isNotEmpty) {
        listener[_currentAnswers.first].value = () {};
        //remove
        _currentAnswers.clear();
      }
      // set item selected
      _currentAnswers.add(index);
    } else {
      //unchoose
      _currentAnswers.clear();
    }
  }
}
