import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';
import 'package:the_flashcard/login/login_email_screen.dart';

import 'login_bloc.dart';

class LoginFacebookScreen extends StatefulWidget {
  static final name = '/login_facebook_screen';

  @override
  _LoginFacebookScreenState createState() => _LoginFacebookScreenState();
}

class _LoginFacebookScreenState extends XState<LoginFacebookScreen> {
  AuthenticationBloc authBloc;
  LoginBloc bloc;
  // FacebookLogin facebookLogin;
  bool enableClick;

  @override
  void initState() {
    super.initState();
    _portraitModeOnly();
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    bloc = LoginBloc();
    // facebookLogin = FacebookLogin();
    enableClick = true;
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        bloc: bloc,
        listener: _onStateChanged,
        builder: (_, state) {
          return LayoutBuilder(
            builder: (layoutContext, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        Flexible(
                          flex: 8,
                          child: ClipPath(
                            clipper: OvalBottomBorderClipper(),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    XedColors.pastelRed,
                                    XedColors.waterMelon,
                                  ],
                                  stops: [
                                    0.0,
                                    1.0,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Flex(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SvgPicture.asset(
                                        Assets.imgBubbleChatLogin),
                                  ),
                                  SvgPicture.asset(Assets.imgSmileLogin),
                                  Spacer(flex: 4),
                                  _buildTitle("Hey there!"),
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30),
                                    child: _buildDescription(
                                        "Welcome to our community. Your journey starts here."),
                                  ),
                                  Spacer(
                                    flex: 7,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30)
                                .copyWith(bottom: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Spacer(),
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 16),
                                  height: 55,
                                  child: XedButtons.colorCTA(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SvgPicture.asset(
                                          Assets.icFacebook,
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 14),
                                          padding: EdgeInsets.only(
                                            top: 5,
                                          ),
                                          child: Text(
                                            "Sign in with Facebook",
                                            style:
                                                SemiBoldTextStyle(18).copyWith(
                                              color: XedColors.white255,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        state.isSubmitting
                                            ? XedProgress.indicator(
                                                color: XedColors.white255)
                                            : SizedBox(),
                                      ],
                                    ),
                                    color: XedColors.deepSkyBlueTwo,
                                    borderRadius: BorderRadius.circular(27.5),
                                    onTap: () {
                                      if (!state.isSubmitting && enableClick) {
                                        XError.f1(
                                            _onTapLoginFacebook, layoutContext);
                                        enableClick = false;
                                      }
                                    },
                                  ),
                                ),
                                InkWell(
                                  onTap: onTapLoginEmail,
                                  child: Text(
                                    "Sign in with Email",
                                    textAlign: TextAlign.center,
                                    style: RegularTextStyle(16).copyWith(
                                      color: XedColors.color_178_178_178,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                _buildLicense(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state.isFailure) {
      showErrorSnakeBar(state.error, context: context);
      enableClick = true;
    } else if (state.isSuccess) {
      showSuccessSnakeBar(core.Config.getString("msg_login_success"),
          context: context);
      enableClick = true;
    }
  }

  void onTapLoginEmail() {
    navigateToScreen(
      screen: LoginEmailScreen(),
      name: LoginEmailScreen.name,
    );
  }

  void _onTapLoginFacebook(BuildContext context) {
    // Analytics.log("do_login_with_facebook", {});
    // _getFacebookLoginResult(facebookLogin).then((result) {
    //   core.Log.debug(
    //       'login_form :: _onTapLoginFacebook :: Facebook result status: ${result.status}');
    //   switch (result.status) {
    //     case FacebookLoginStatus.loggedIn:
    //       _handleLoggedIn(result);
    //       break;
    //     case FacebookLoginStatus.error:
    //       _handleError(result, context);
    //       break;
    //     default:
    //   }
    // });
  }

  // void _handleError(FacebookLoginResult result, BuildContext context) {
  //   core.Log.debug(
  //       'login_form :: _handleError :: Facebook result error: ${result.errorMessage}');
  //   showErrorSnakeBar(result.errorMessage, context: context);
  //   enableClick = true;
  // }
  //
  // void _handleLoggedIn(FacebookLoginResult result) {
  //   final String token = result.accessToken.token;
  //   final String userId = result.accessToken.userId;
  //   bloc.add(FacebookPressed(token: token, userId: userId));
  // }
  //
  // Future<FacebookLoginResult> _getFacebookLoginResult(
  //     FacebookLogin facebookLogin) {
  //   return facebookLogin.logIn(['email']);
  // }

  Widget _buildLicense() {
    return FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          String license = "Coppy right © 2020 KIKI SJC.\nAll Rights Reserved";
          if (snapshot.hasData) {
            license =
                "Coppy right © 2020 KIKI SJC.\nAll Rights Reserved - Version ${snapshot.data.version}";
          }
          return Text(
            license,
            textAlign: TextAlign.center,
            style: RegularTextStyle(12).copyWith(
              color: XedColors.color_178_178_178,
              fontSize: 12,
              height: 1.4,
            ),
          );
        });
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: RegularTextStyle(18).copyWith(
        color: XedColors.white255,
        fontSize: 18,
        height: 1.4,
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: SemiBoldTextStyle(24).copyWith(
        color: XedColors.white255,
        fontSize: 24,
      ),
    );
  }
}
