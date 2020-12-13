import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/widgets/x_choice_widget.dart';
import 'package:the_flashcard/common/xwidgets/xwidgets.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class ChoiceAnswerWidget extends StatelessWidget {
  final core.MultiChoice component;
  final AnswerCallBack onTap;
  final XComponentMode mode;

  ChoiceAnswerWidget({
    Key key,
    this.component,
    this.onTap,
    this.mode = XComponentMode.Review,
  }) : super(key: key);

  final List<Widget> components = [];

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildQuestion(),
        SizedBox(height: 15),
        _buildAnswer(context),
      ],
    );
  }

  Widget _buildAnswer(BuildContext context) {
    final bloc = BlocProvider.of<MCStepTwoBloc>(context);
    return BlocBuilder<MCStepTwoBloc, MCState>(
      cubit: bloc,
      buildWhen: (_, MCState state) {
        return state is InitState || state is RequestionChangeButton;
      },
      builder: (_, MCState state) {
        bool isRadioButton = bloc.isRadioButton;
        if (state is RequestionChangeButton)
          isRadioButton = state.isRadioButton;
        return _isOnlyText()
            ? _buildTextAnswer(isRadioButton)
            : _buildMultiComponentAnswer(isRadioButton);
      },
    );
  }

  Widget _buildQuestion() {
    core.TextConfig textConfig = component.textConfig;
    return Text(
      textConfig?.isUpperCase == true
          ? component.question.toUpperCase()
          : component.question,
      textAlign: textConfig?.toTextAlign() ?? TextAlign.left,
      style: textConfig?.toTextStyle(),
    );
  }

  bool _isOnlyText() {
    return component.answers.firstWhere(
      (item) => item.hasUrl(),
      orElse: () => null,
    ) is core.Answer
        ? false
        : true;
  }

  Widget _buildMultiComponentAnswer(bool isRadioButton) {
    double heightSpacer = hp(10);
    double widthSpacer = wp(12);

    return StaggeredGridView.countBuilder(
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: heightSpacer,
      mainAxisSpacing: widthSpacer,
      itemCount: component.answers.length,
      itemBuilder: (_, i) => XAnswerChoiceWidget(
        valueKey: DriverKey.MULTI_RIGHT_ANSWER + "_$i",
        component: component.answers[i],
        onTap: onTap != null
            ? (answer, selected) =>
                XError.f2<core.Answer, bool>(onTap, answer, selected)
            : null,
        isRadioButton: isRadioButton,
        mode: mode,
        isSelected: component.answers[i].correct,
      ),
      staggeredTileBuilder: (_) => StaggeredTile.fit(2),
    );
  }

  Widget _buildTextAnswer(bool isRadioButton) {
    double heightSpacer = hp(10);
    SizedBox spacer = SizedBox(height: heightSpacer);
    return ListView.separated(
      itemCount: component.answers.length,
      shrinkWrap: true,
      itemBuilder: (_, int i) {
        return XAnswerChoiceWidget(
          valueKey: DriverKey.MULTI_RIGHT_ANSWER + "_$i",
          component: component.answers[i],
          onTap: onTap != null
              ? (answer, selected) =>
                  XError.f2<core.Answer, bool>(onTap, answer, selected)
              : null,
          isRadioButton: isRadioButton,
          isOnlyText: true,
          mode: mode,
          isSelected: component.answers[i].correct,
        );
      },
      separatorBuilder: (_, int index) => spacer,
    );
  }
}
