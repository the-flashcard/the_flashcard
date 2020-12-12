import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/widgets/x_edit_text_view.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/login/forget_password/forget_screen_two.dart';
import 'package:the_flashcard/login/login_email_screen.dart';

class ForgetScreenOne extends StatefulWidget {
  ForgetScreenOne({Key key}) : super(key: key);

  _ForgetScreenOneState createState() => _ForgetScreenOneState();
}

class _ForgetScreenOneState extends XState<ForgetScreenOne> {
  String errorText;
  bool isEmailValid = false;
  bool isSending = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                AppbarStepOne(
                  text: "Fill Email",
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: hp(43.0), left: wp(20.0), right: wp(20.0)),
                  child: XEditTextView(
                    _emailController,
                    'Email',
                    'name@mail.com',
                    false,
                    onChanged: handleEmailChanged,
                    errorText: errorText,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: wp(20), vertical: hp(20)),
                  child: XedButtons.watermelonButton(
                    "Next",
                    10,
                    18,
                    (isEmailValid && !isSending)
                        ? () => handleTapNext(_emailController.text ?? '')
                        : null,
                    width: double.infinity,
                    height: hp(56),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                heroTag: "close",
                child: Icon(Icons.close),
                onPressed: () => XError.f0(() => _goBackToLoginScreen(context)),
                backgroundColor: XedColors.battleShipGrey,
              ),
            )
          ],
        ),
      ),
    );
  }

  handleEmailChanged(String email) {
    try {
      if (!core.EmailUtils.isValidEmail(email.trim().toLowerCase())) {
        errorText = 'Email is invalid';
        isEmailValid = false;
      } else {
        errorText = null;
        isEmailValid = true;
      }
      reRender();
    } catch (ex) {
      core.Log.error(ex);
      showErrorSnakeBar(core.Config.getString('msg_something_went_wrong'));
    }
  }

  handleTapNext(String email) async {
    try {
      isSending = true;
      reRender();
      await navigateToScreen(
        screen: ForgetScreenTwo(email.trim().toLowerCase()),
        name: ForgetScreenTwo.name,
      );
    } catch (ex) {
      core.Log.error(ex);
      showErrorSnakeBar(core.Config.getString('msg_something_went_wrong'));
    } finally {
      isSending = false;
      reRender();
    }
  }

  void _goBackToLoginScreen(BuildContext context) {
    closeUntil(LoginEmailScreen.name, context: context);
  }
}
