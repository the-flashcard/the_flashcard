import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_verify_edit_text.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';

import 'package:the_flashcard/login/verify_bloc.dart';

class VerificationScreen extends StatefulWidget {
  static const name = "verification_screen";
  final String _email;

  VerificationScreen(this._email);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends XState<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  VerifyBloc verifyBloc;
  AuthenticationBloc authBloc;
  bool isCodeCompleted = true;

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    verifyBloc = VerifyBloc(authenticationBloc: authBloc);
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    // var height56 = hp(56);
    // var height34 = hp(34);
    // var width51 = wp(51);
    // var height18 = hp(18);
    var height52 = hp(52);
    var height67 = hp(67);
    var height44 = hp(44);
    var height46 = hp(46);
    var height16 = hp(16);
    var width103 = wp(103);
    var width20 = wp(20);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => XError.f0(
              () => _onBackPressed(context),
            ),
          ),
        ),
        body: BlocListener(
          cubit: verifyBloc,
          listener: (context, state) => _onVerifiedStateChanged(context, state),
          child: BlocBuilder<VerifyBloc, VerifyState>(
              cubit: verifyBloc,
              builder: (BuildContext context, VerifyState state) {
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: height52),
                          height: height67,
                          width: width103,
                          child: Image.asset(
                            'assets/verify/shutterstock1205161000@3x.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height44),
                          child: Text(
                            state.isResending
                                ? 'Sending...'
                                : core.Config.getString(
                                    "msg_verification_code_sent"),
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'HarmoniaSansProCyr',
                                fontWeight: FontWeight.w400,
                                color: XedColors.battleShipGrey),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height16),
                          child: Text(
                            widget._email,
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'HarmoniaSansProCyr',
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        XVerifyEditTextView(
                          totalNumberOfDigits: 6,
                          controller: _codeController,
                          onCompleted: (digits) => _onCodeCompleted(verifyBloc),
                          onUnCompleted: (digits) =>
                              _onCodeUnCompleted(verifyBloc),
                        ),
                        SizedBox(
                          height: 34,
                        ),
                        Container(
                          child: RichText(
                            text: TextSpan(
                                text: 'Didn’t receive the code?',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'HarmoniaSansProCyr',
                                    fontWeight: FontWeight.w400,
                                    color: XedColors.battleShipGrey),
                                children: [
                                  TextSpan(
                                    text: '  RESEND',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = (!state.isResending &&
                                              !state.isSubmitting)
                                          ? () => XError.f0(() =>
                                              _onResendPressed(verifyBloc))
                                          : null,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'HarmoniaSansProCyr',
                                        fontWeight: FontWeight.w600,
                                        color: XedColors.waterMelon),
                                  )
                                ]),
                          ),
                        ),
                        Container(
                          height: 56.0,
                          margin: EdgeInsets.only(
                              left: width20, right: width20, top: height46),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: state.isCodeValid
                                ? XedColors.waterMelon
                                : XedColors.brownGrey,
                          ),
                          child: InkWell(
                            onTap: (state.isCodeValid &&
                                    !state.isResending &&
                                    !state.isSubmitting)
                                ? () => XError.f0(
                                    () => _onVerifyButtonPressed(verifyBloc))
                                : null,
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontFamily: 'HarmoniaSansProCyr',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                                state.isSubmitting
                                    ? Row(children: <Widget>[
                                        SizedBox(width: 30.0),
                                        XedProgress.indicator()
                                      ])
                                    : SizedBox(width: 0.0)
                              ],
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ));
  }

  void _onBackPressed(BuildContext context) {
    //True: stop verify & back to previous screen
    Navigator.pop(context, true);
  }

  void _onCodeCompleted(VerifyBloc bloc) {
    bloc.add(VerifyCodeCompleted());
  }

  void _onCodeUnCompleted(VerifyBloc bloc) {
    bloc.add(VerifyCodeUnCompleted());
  }

  void _onResendPressed(VerifyBloc bloc) {
    bloc.add(ResendCodeEvent(email: widget._email));
  }

  void _onVerifyButtonPressed(VerifyBloc bloc) {
    bloc.add(VerifyPressedEvent(
      email: widget._email,
      code: _codeController.text,
    ));
  }

  void _onVerifiedStateChanged(BuildContext context, VerifyState state) async {
    if (state.isSuccess) {
      Navigator.pop(context);
      authBloc.add(LoggedIn(state.loginData));
    } else if (state.isSent) {
      showSuccessSnakeBar(core.Config.getString("msg_sent_success"),
          context: context);
    } else if (state.isFailure) {
      showErrorSnakeBar(state.error, context: context);
    }
  }
}
