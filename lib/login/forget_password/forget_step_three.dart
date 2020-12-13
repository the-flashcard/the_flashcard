import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/widgets/x_edit_text_view.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/login/forget_password/bloc/forget_password_bloc.dart';

class ForgetStepThree extends StatefulWidget {
  final ForgetPasswordBloc bloc;
  ForgetStepThree(this.bloc, {Key key}) : super(key: key);

  _ForgetStepThreeState createState() => _ForgetStepThreeState();
}

class _ForgetStepThreeState extends XState<ForgetStepThree> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _reNewPassController = TextEditingController();
  String errorNewPass;
  String errorRePass;
  bool canReset = false;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Builder(
        builder: (context) => Column(
          children: <Widget>[
            SizedBox(height: hp(43)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: wp(20)),
              child: XEditTextView(
                _newPassController,
                'New password',
                '••••••••',
                true,
                onChanged: (password) =>
                    XError.f0(() => handleNewPassChanged(password)),
                errorText: errorNewPass,
              ),
            ),
            SizedBox(height: hp(28)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: wp(20)),
              child: XEditTextView(
                _reNewPassController,
                'Re-type new password',
                '••••••••',
                true,
                onChanged: (password) =>
                    XError.f0(() => handleReNewPassChanged(password)),
                errorText: errorRePass,
              ),
            ),
            SizedBox(height: hp(40)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: wp(20)),
              child: XedButtons.watermelonButton(
                'Reset and Sign In',
                10,
                18,
                (canReset && !isSubmitting)
                    ? () => handleTapReset(context, widget.bloc.email,
                        _newPassController.text.trim())
                    : null,
                width: double.infinity,
                height: hp(56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  handleNewPassChanged(String password) {
    if (!core.EmailUtils.isValidPassword(password.trim())) {
      setState(() {
        errorNewPass = core.Config.getString("msg_new_password_invalid");
      });
    } else {
      setState(() {
        errorNewPass = null;
      });
    }
  }

  handleReNewPassChanged(String rePassword) {
    if (!core.EmailUtils.isValidPassword(rePassword.trim())) {
      setState(() {
        errorRePass = core.Config.getString("msg_retype_password_invalid");
      });
    } else if (rePassword.trim() != _newPassController.text.trim()) {
      setState(() {
        errorRePass = core.Config.getString("msg_password_not_match");
        canReset = _canSubmit(errorNewPass, errorRePass);
      });
    } else {
      setState(() {
        errorRePass = null;
        canReset = _canSubmit(errorNewPass, errorRePass);
      });
    }
  }

  handleTapReset(BuildContext context, String email, String newPass) async {
    try {
      setState(() {
        isSubmitting = true;
      });
      AuthenticationBloc authenBloc = DI.get(AuthenticationBloc);

      core.AuthService authService = DI.get(core.AuthService);
      core.LoginData loginData =
          await authService.changePassword(email, widget.bloc.token, newPass);

      closeUntilRootScreen(context: context);
      authenBloc.add(LoggedIn(loginData));
    } on core.APIException catch (e) {
      String errorMessage = '${e.reason} - ${e.message}';
      showErrorSnakeBar(errorMessage, context: context);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  bool _canSubmit(String errorNewPass, String errorRePass) {
    return errorNewPass == null && errorRePass == null;
  }
}
