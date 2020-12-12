import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_edit_text_view.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/login/forget_password/forget_screen_one.dart';
import 'package:the_flashcard/login/verification_screen.dart';

import 'login_bloc.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends XState<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc bloc;
  // final facebookLogin = FacebookLogin();

  @override
  void initState() {
    super.initState();
    bloc = LoginBloc();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double width20 = width * 0.05;
    return BlocConsumer<LoginBloc, LoginState>(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(context, state),
      builder: (BuildContext context, LoginState state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: width20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 45.0),
                XEditTextView(
                  _emailController,
                  'Email',
                  'name@mail.com',
                  false,
                  onChanged: (email) => XError.f0(() => _onEmailChanged(email)),
                  errorText: state.emailErrorText,
                  valueKey: DriverKey.LOGIN_EMAIL,
                ),
                SizedBox(height: 20.0),
                XEditTextView(
                  _passwordController,
                  'Password',
                  '••••••••',
                  true,
                  onChanged: (password) =>
                      XError.f0(() => _onPasswordChanged(password)),
                  errorText: state.passwordErrorText,
                  valueKey: DriverKey.LOGIN_PASSWORD,
                ),
                SizedBox(height: 30.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'HarmoniaSansProCyr',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                        color: Color.fromARGB(255, 253, 68, 104),
                      ),
                    ),
                    onTap: () => XError.f0(_onTapForgotPassword),
                  ),
                ),
                SizedBox(height: 40.0),
                Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: (state.isFormValid)
                        ? XedColors.waterMelon
                        : XedColors.brownGrey,
                  ),
                  child: InkWell(
                    onTap: (state.isFormValid && !state.isSubmitting)
                        ? () => XError.f0(_onLoginButtonPressed)
                        : null,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Sign In",
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
                                XedProgress.indicator(color: XedColors.white)
                              ])
                            : SizedBox(width: 0.0),
                      ],
                    )),
                    key: Key(DriverKey.LOGIN_SIGN_IN),
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Or login with social media',
                      style: TextStyle(
                        fontFamily: 'HarmoniaSansProCyr',
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0,
                        color: Color.fromARGB(255, 43, 43, 43),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 44.0,
                          height: 44.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(
                              color: Color.fromARGB(255, 43, 43, 43),
                            ),
                          ),
                          child: InkWell(
                            child: Icon(FontAwesome.facebook),
                            onTap: () => XError.f0(_onTapLoginFacebook),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state.isVerificationRequired) {
      _navigateToVerificationScreen(state.email);
    } else if (state.isFailure) {
      showErrorSnakeBar(state.error, context: context);
    } else if (state.isSuccess) {
      showSuccessSnakeBar(core.Config.getString("msg_login_success"),
          context: context);
    }
  }

  void _onEmailChanged(String email) {
    bloc.add(EmailChanged(email.trim().toLowerCase()));
  }

  void _onPasswordChanged(String password) {
    bloc.add(PasswordChanged(password.trim()));
  }

  void _onLoginButtonPressed() {
    bloc.add(LoginPressed(
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
    ));
  }

  void _navigateToVerificationScreen(String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(email),
        settings: RouteSettings(name: VerificationScreen.name),
      ),
    );
  }

  void _onTapLoginFacebook() {
    // _getFacebookLoginResult(facebookLogin).then((result) {
    //   core.Log.debug(
    //       'login_form :: _onTapLoginFacebook :: Facebook result status: ${result.status}');
    //   switch (result.status) {
    //     case FacebookLoginStatus.loggedIn:
    //       _handleLoggedIn(result);
    //       break;
    //     case FacebookLoginStatus.error:
    //       _handleError(result);
    //       break;
    //     default:
    //   }
    // });
  }

  // Future<FacebookLoginResult> _getFacebookLoginResult(
  //     FacebookLogin facebookLogin) {
  //   return facebookLogin.logIn(['email']);
  // }
  //
  // void _handleError(FacebookLoginResult result) {
  //   core.Log.debug(
  //       'login_form :: _handleError :: Facebook result error: ${result.errorMessage}');
  //   showErrorSnakeBar(result.errorMessage);
  // }
  //
  // void _handleLoggedIn(FacebookLoginResult result) {
  //   final String token = result.accessToken.token;
  //   final String userId = result.accessToken.userId;
  //   bloc.add(
  //     FacebookPressed(token: token, userId: userId),
  //   );
  // }

  void _onTapForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgetScreenOne()),
    );
  }

  @override
  void dispose() {
    _emailController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }
}
