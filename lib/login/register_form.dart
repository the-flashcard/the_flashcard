import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/widgets/x_edit_text_view.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';
import 'package:the_flashcard/login/register_bloc.dart' as regist;
import 'package:the_flashcard/login/verification_screen.dart';

class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends XState<RegisterForm> {
  regist.RegisterBloc bloc;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    bloc = regist.RegisterBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double width20 = width * 0.05;

    return BlocListener(
      bloc: bloc,
      listener: (context, state) => _onStateChanged(context, state),
      child: BlocBuilder<regist.RegisterBloc, regist.RegisterState>(
        bloc: bloc,
        builder: (BuildContext context, regist.RegisterState state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 45.0),
                  XEditTextView(
                    _nameController,
                    'Full Name',
                    'Your name',
                    false,
                    onChanged: (fullName) =>
                        XError.f0(() => _onFullNameChanged(fullName)),
                    errorText: state.fullNameErrorText,
                  ),
                  SizedBox(height: 20.0),
                  XEditTextView(
                    _emailController,
                    'Email',
                    'Your email',
                    false,
                    onChanged: (email) => XError.f0(
                        () => _onEmailChanged(email.trim().toLowerCase())),
                    errorText: state.emailErrorText,
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
                  ),
                  SizedBox(height: 40.0),
                  InkWell(
                      child: Container(
                        height: 56.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: state.isFormValid
                              ? XedColors.waterMelon
                              : XedColors.brownGrey,
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Register Now",
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
                                    XedProgress.indicator(
                                        color: XedColors.white)
                                  ])
                                : SizedBox(width: 0.0)
                          ],
                        )),
                      ),
                      onTap: (state.isFormValid && !state.isSubmitting)
                          ? () => _onRegisterButtonPressed(bloc)
                          : null),
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
      ),
    );
  }

  void _onRegisterButtonPressed(regist.RegisterBloc bloc) {
    bloc.add(regist.RegisterPressed(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text.trim(),
    ));
  }

  void _onStateChanged(BuildContext context, regist.RegisterState state) {
    if (state.isSuccess) {
      _onRegisterSuccess(context, state.profile);
    } else if (state.isFailure) {
      showErrorSnakeBar(state.error, context: context);
    }
  }

  void _onRegisterSuccess(BuildContext context, core.UserProfile profile) {
    showSuccessSnakeBar(core.Config.getString("msg_login_success"),
        context: context);

    // if(!profile.alreadyConfirmed) {
    //   _navigateToVerificationScreen(profile.email);
    // }else {
    //   //Todo: Login successfully
    // }
  }

  void _onFullNameChanged(String fullName) {
    bloc.add(regist.FullNameChanged(fullName.trim()));
  }

  void _onEmailChanged(String email) {
    bloc.add(regist.EmailChanged(email.trim()));
  }

  void _onPasswordChanged(String password) {
    bloc.add(regist.PasswordChanged(password.trim()));
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

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }
}
