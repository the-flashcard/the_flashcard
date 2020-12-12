import 'package:ddi/di.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_verify_edit_text.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/login/forget_password/forget_screen_three.dart';
import 'package:the_flashcard/login/login_email_screen.dart';

class ForgetScreenTwo extends StatefulWidget {
  final String email;
  static const name = 'forget_screen_two';

  ForgetScreenTwo(this.email, {Key key}) : super(key: key);

  _ForgetScreenTwoState createState() => _ForgetScreenTwoState();
}

class _ForgetScreenTwoState extends XState<ForgetScreenTwo> {
  bool _isResending = false;
  bool _isSubmitting = false;
  bool _isCodeValid = false;
  String _code = '';
  String _token = '';
  TextEditingController codeController;
  core.AuthService authService;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
    authService = DI.get(core.AuthService);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await authService.forgetPassword(widget.email);
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
      }
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    var height52 = hp(52);
    var height67 = hp(67);
    var height44 = hp(44);
    var height46 = hp(46);
    var height16 = hp(16);
    var width103 = wp(103);
    var width20 = wp(20);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AppbarStepTwo(text: "Verify email"),
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
                  _isResending
                      ? 'Sending...'
                      : core.Config.getString("msg_verification_code_sent"),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'HarmoniaSansProCyr',
                    fontWeight: FontWeight.w400,
                    color: XedColors.battleShipGrey,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height16),
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'HarmoniaSansProCyr',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Builder(
                builder: (_) => XVerifyEditTextView(
                  totalNumberOfDigits: 6,
                  controller: codeController,
                  onCompleted: (digits) => handleCodeCompleted(digits),
                  onUnCompleted: (digits) => handleCodeUnCompleted(),
                ),
              ),
              SizedBox(height: 34),
              Container(
                child: RichText(
                  text: TextSpan(
                      text: core.Config.getString("msg_not_received_code"),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'HarmoniaSansProCyr',
                        fontWeight: FontWeight.w400,
                        color: XedColors.battleShipGrey,
                      ),
                      children: [
                        TextSpan(
                          text: '  RESEND',
                          recognizer: TapGestureRecognizer()
                            ..onTap = (!_isResending && !_isSubmitting)
                                ? () => XError.f0(
                                    () => handleTapResend(widget.email))
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
                    onTap: (_isCodeValid && !_isResending && !_isSubmitting)
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
                          _isSubmitting
                              ? Row(children: <Widget>[
                                  SizedBox(width: 30.0),
                                  XedProgress.indicator()
                                ])
                              : SizedBox(width: 0.0)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: hp(30)),
              Text(
                core.Config.getString("msg_ask_check_inbox"),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'HarmoniaSansProCyr',
                  fontWeight: FontWeight.w400,
                  color: XedColors.battleShipGrey,
                ),
              ),
              SizedBox(height: hp(65)),
              Padding(
                padding: EdgeInsets.only(bottom: hp(30)),
                child: FloatingActionButton(
                  heroTag: "close",
                  child: Icon(Icons.close),
                  onPressed: () =>
                      XError.f0(() => _goBackToLoginScreen(context)),
                  backgroundColor: XedColors.battleShipGrey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleCodeCompleted(List<String> digits) {
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
    try {
      _isSubmitting = true;
      reRender();
      _token = await authService.verifyForgetPassword(widget.email, _code);
      if (_token?.isNotEmpty ?? false) {
        navigateToScreen(
          screen: ForgetScreenThree(widget.email, _token),
        );
      }
    } on core.APIException catch (e) {
      String errorMessage = '';
      switch (e.reason) {
        case core.ApiErrorReasons.QuotaExceed:
          errorMessage = core.Config.getString("msg_limit_reached");
          break;
        case core.ApiErrorReasons.VerificationCodeInvalid:
          errorMessage = core.Config.getString("msg_code_invalid");
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
        _isSubmitting = false;
      });
    }
  }

  void _goBackToLoginScreen(BuildContext context) {
    closeUntil(LoginEmailScreen.name, context: context);
  }
}
