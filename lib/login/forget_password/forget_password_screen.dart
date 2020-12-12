import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/login/forget_password/appbar_step_widget.dart';
import 'package:the_flashcard/login/forget_password/bloc/forget_password_bloc.dart';

import 'forget_step_one.dart';
import 'forget_step_three.dart';
import 'forget_step_two.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const name = '/forget_password_screen';
  ForgetPasswordScreen({Key key}) : super(key: key);

  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends XState<ForgetPasswordScreen> {
  PageController pageController;
  ForgetPasswordBloc forgetBloc;
  final Map<int, String> stepTitleMap = {
    1: "Fill Email",
    2: "Verify email",
    3: "Reset and Sign In",
  };
  int currentStep;
  @override
  void initState() {
    super.initState();
    currentStep = 1;
    pageController = PageController();
    forgetBloc = ForgetPasswordBloc();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ForgetPasswordBloc, ForgetPasswordState>(
        listener: (context, state) {
          if (state.isSuccess && state.nextStep) {
            currentStep++;
            pageController.jumpToPage(currentStep - 1);
            unfocus();
          } else if (state.isFailure && state.errorMessage.isNotEmpty) {
            showErrorSnakeBar(state.errorMessage, context: context);
          }
        },
        bloc: forgetBloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppbarStepWidget(
              stepTitleMap[currentStep] ?? '',
              currentStep: currentStep,
            ),
            body: Stack(
              children: <Widget>[
                PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: <Widget>[
                    ForgetStepOne(forgetBloc),
                    ForgetStepTwo(forgetBloc),
                    ForgetStepThree(forgetBloc),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              color: Colors.transparent,
              child: FloatingActionButton(
                heroTag: "close",
                child: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: XedColors.battleShipGrey,
              ),
            ),
          );
        },
      ),
    );
  }
}
