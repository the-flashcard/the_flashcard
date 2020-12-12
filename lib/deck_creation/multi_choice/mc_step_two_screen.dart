import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';

class MCStepTwoScreen extends StatefulWidget {
  static String name = '/deckMultiCreation2';
  final core.MultiChoice choice;

  MCStepTwoScreen(this.choice);

  @override
  _MCStepTwoScreenState createState() => _MCStepTwoScreenState();
}

class _MCStepTwoScreenState extends State<MCStepTwoScreen> {
  MCStepTwoBloc bloc;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = MCStepTwoBloc.edit(widget.choice);
  }

  @override
  Widget build(BuildContext context) {
    final double spacer = hp(44);
    controller.text = bloc.choice.question;
    return BlocListener(
      bloc: bloc,
      listener: (_, MCState state) {
        if (state is RequestionPreviousScreen) Navigator.of(context).pop();
        if (state is RequestionNextScreen)
          Navigator.of(context).pushNamed(
            MultiCreationPreviewScreen.name,
            arguments: state.answers,
          );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocProvider(
            create: (_) => bloc,
            child: Stack(
              children: [
                AppbarStepTwo(
                    text: core.Config.getString("msg_choose_correct_answer")),
                Container(
                  margin: EdgeInsets.fromLTRB(20, hp(65), 20, 0),
                  child: SingleChildScrollView(
                    child: Flex(
                      mainAxisSize: MainAxisSize.max,
                      direction: Axis.vertical,
                      children: <Widget>[
                        ChoiceAnswerWidget(
                          component: bloc.choice,
                          onTap: (answer, selected) =>
                              XError.f2<core.Answer, bool>(
                            _choiceComponent,
                            answer,
                            selected,
                          ),
                          mode: XComponentMode.Editing,
                        ),
                        SizedBox(height: spacer),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocBuilder<MCStepTwoBloc, MCState>(
                    bloc: bloc,
                    condition: (_, state) {
                      return state is InitState ||
                          state is RequestionNextOn ||
                          state is RequestionNextOff;
                    },
                    builder: (_, MCState state) {
                      return Container(
                        color: XedColors.waterMelon,
                        height: spacer,
                        width: double.infinity,
                        child: BottomActionBarWidget(
                          left: 'Previous',
                          onTapLeft: _previous,
                          next: state is RequestionNextOn || bloc.nextScreen,
                          onTapRight: _nextScreen,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _previous() {
    bloc.add(RequestionPreviousEvent());
  }

  void _choiceComponent(core.Answer answer, bool isSelected) {
    bloc.add(ChoiceAnswerEvent(answer));
  }

  void _nextScreen() {
    bloc.add(RequestionNextEvent());
  }
}
