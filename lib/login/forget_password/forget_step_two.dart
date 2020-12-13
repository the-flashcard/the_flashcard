import 'package:ddi/di.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_verify_edit_text.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';
import 'package:the_flashcard/login/forget_password/bloc/forget_password_bloc.dart';

class ForgetStepTwo extends StatefulWidget {
  final ForgetPasswordBloc forgetBloc;
  ForgetStepTwo(this.forgetBloc, {Key key}) : super(key: key);

  _ForgetStepTwoState createState() => _ForgetStepTwoState();
}

class _ForgetStepTwoState extends XState<ForgetStepTwo> {
  bool _isResending = false;
  bool _isCodeValid = false;
  String _code = '';
  TextEditingController codeController;
  core.AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = DI.get(core.AuthService);
    codeController = TextEditingController();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height52 = hp(52);
    var height67 = hp(70);
    var height44 = hp(44);
    var height46 = hp(46);
    var height16 = hp(16);
    var width103 = wp(103);
    var width20 = wp(20);
    return BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
      cubit: widget.forgetBloc,
      builder: (_, state) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  _isResending || state.isLoading
                      ? 'Sending...'
                      : core.Config.getString("msg_verification_code_sent"),
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
                  widget.forgetBloc.email,
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
                controller: codeController,
                onCompleted: (digits) => handleCodeCompleted(digits),
                onUnCompleted: (digits) => handleCodeUnCompleted(),
              ),
              SizedBox(
                height: 34,
              ),
              Container(
                child: RichText(
                  text: TextSpan(
                      text: core.Config.getString("msg_not_received_code"),
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'HarmoniaSansProCyr',
                          fontWeight: FontWeight.w400,
                          color: XedColors.battleShipGrey),
                      children: [
                        TextSpan(
                          text: '  RESEND',
                          recognizer: TapGestureRecognizer()
                            ..onTap = (!_isResending && !state.isLoading)
                                ? () => XError.f0(
                                      () => handleTapResend(
                                          widget.forgetBloc.email),
                                    )
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
              Builder(
                builder: (context) => Container(
                  height: 56.0,
                  margin: EdgeInsets.only(
                      left: width20, right: width20, top: height46),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: _isCodeValid
                        ? XedColors.waterMelon
                        : XedColors.brownGrey,
                  ),
                  child: InkWell(
                    onTap: (_isCodeValid && !_isResending && !state.isLoading)
                        ? handleTapVerifyButton
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
                        state.isLoading
                            ? Row(children: <Widget>[
                                SizedBox(width: 30.0),
                                XedProgress.indicator()
                              ])
                            : SizedBox(width: 0.0)
                      ],
                    )),
                  ),
                ),
              ),
              SizedBox(
                height: hp(30),
              ),
              Text(
                core.Config.getString("msg_ask_check_inbox"),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'HarmoniaSansProCyr',
                  fontWeight: FontWeight.w400,
                  color: XedColors.battleShipGrey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  handleCodeCompleted(List<String> digits) {
    setState(() {
      FocusScope.of(context).unfocus();
      _isCodeValid = true;
      digits.forEach((digit) => _code += digit);
    });
  }

  handleCodeUnCompleted() {
    setState(() {
      _isCodeValid = false;
      if (_code.isNotEmpty) _code = '';
    });
  }

  handleTapResend(String email) async {
    try {
      _isResending = true;
      _isCodeValid = false;
      reRender();
      bool isSuccess = await authService.forgetPassword(email.trim());
      if (isSuccess) {
        showSuccessSnakeBar(core.Config.getString("msg_code_sent_success"),
            context: context);
      }
    } on core.APIException catch (e) {
      String errorMessage = '';
      switch (e.reason) {
        case core.ApiErrorReasons.QuotaExceed:
          errorMessage = core.Config.getString("msg_limit_reached");
          break;
        case core.ApiErrorReasons.EmailNotExisted:
          errorMessage = core.Config.getString("msg_email_not_existed");
          break;
        default:
          errorMessage = '${e.reason} - ${e.message}';
      }
      showErrorSnakeBar(errorMessage, context: context);
    } catch (ex) {
      core.Log.error(ex);
      showErrorSnakeBar(core.Config.getString('msg_something_went_wrong'));
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void handleTapVerifyButton() async {
    widget.forgetBloc.add(SubmitCode(_code));
  }
}
