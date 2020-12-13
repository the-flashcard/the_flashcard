import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/widgets/x_edit_text_view.dart';
import 'package:the_flashcard/login/forget_password/bloc/forget_password_bloc.dart';

class ForgetStepOne extends StatefulWidget {
  final ForgetPasswordBloc forgetBloc;
  ForgetStepOne(this.forgetBloc, {Key key}) : super(key: key);

  _ForgetStepOneState createState() => _ForgetStepOneState();
}

class _ForgetStepOneState extends XState<ForgetStepOne> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
      cubit: widget.forgetBloc,
      builder: (context, state) {
        return Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: (43.0), left: (20.0), right: (20.0)),
              child: XEditTextView(
                _emailController,
                'Email',
                'name@mail.com',
                false,
                onChanged: handleEmailChanged,
                errorText: !state.isEmailValid
                    ? core.Config.getString("msg_email_invalid")
                    : null,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: wp(20), vertical: hp(20)),
              child: XedButtons.watermelonButton(
                "Next",
                10,
                18,
                (state.isEmailValid &&
                        _emailController.text.isNotEmpty &&
                        !state.isLoading)
                    ? () => widget.forgetBloc
                        .add(SubmitEmail(_emailController.text.trim() ?? ''))
                    : null,
                width: double.infinity,
                height: 56,
              ),
            ),
          ],
        );
      },
    );
  }

  void handleEmailChanged(String text) {
    widget.forgetBloc.add(TypingEmail(text.trim()));
  }
}
