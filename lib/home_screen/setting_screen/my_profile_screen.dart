import 'dart:io';

import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';

import 'avatar_user_widget.dart';

class MyProfileScreen extends StatefulWidget {
  static const String name = "/my_profile_screen";

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends XState<MyProfileScreen> {
  final authService = DI.get<core.AuthService>(core.AuthService);
  final userProfileService =
      DI.get<core.UserProfileService>(core.UserProfileService);
  AuthenticationBloc authBloc;
  UploadBloc uploadBloc = UploadBloc();
  core.LoginData loginData;
  core.UserProfile userProfile;
  bool isDownloadingImage = false;
  DateTime timeTemporary;

  @override
  void initState() {
    super.initState();
    authBloc = DI.get(AuthenticationBloc);
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: wp(42), right: wp(20)),
            child: SingleChildScrollView(
              child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                bloc: authBloc,
                builder: (context, state) {
                  if (state is Authenticated) {
                    loginData = state.loginData;
                    userProfile = loginData.userProfile;
                    core.Log.debug('avatar: ${userProfile.avatar}');
                  }
                  return BlocListener<UploadBloc, UploadState>(
                    bloc: uploadBloc,
                    listener: (context, state) async {
                      if (state is ImageUploadedSuccess) {
                        updateAvatar(state, loginData);
                      } else if (state is UploadFailed) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.messenge),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: hp(50)),
                        AvatarUserWidget(
                          url: userProfile?.avatar,
                          onTapEdit: () => XError.f1(_onPickAvatar, context),
                        ),
                        SizedBox(height: hp(15)),
                        InkWell(
                          child: Text(
                            '${state is Authenticated ? state.loginData?.userProfile?.fullName ?? '' : ''}',
                            style: RegularTextStyle(20),
                            textAlign: TextAlign.center,
                          ),
                          // onTap: () => XError.f0(() {
                          //   VersionChecker.checkVersion(context);
                          // }),
                        ),
                        SizedBox(height: hp(45)),
                        Divider(
                          indent: wp(36),
                          endIndent: wp(64),
                          height: hp(24),
                          color: Color.fromRGBO(43, 43, 43, 0.1),
                        ),
                        Opacity(
                          opacity: 0.2,
                          child: profileSettingRow(
                            Icon(Icons.star_half),
                            'Rating',
                            null,
                            //() {},
                            null,
                          ),
                        ),
                        Opacity(
                          opacity: 0.2,
                          child: profileSettingRow(
                            Icon(Icons.info_outline),
                            'Report and Feedback',
                            null,
                            null,
                            //() {},
                          ),
                        ),
                        profileSettingRow(
                          SvgPicture.asset(Assets.icLogOut),
                          'Log Out',
                          null,
                          state is Authenticated ? _onLogoutPressed : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: XedButtons.leadingButton(
                onPressed: () => handleCloseScreen(context),
                color: Colors.black),
          ),
          _buildDownloadingImage(isDownloadingImage),
        ],
      ),
    );
  }

  void handleCloseScreen(BuildContext context) {
    try {
      Navigator.of(context).pop();
    } catch (ex) {
      core.Log.error(ex);
    }
  }

  Widget _buildDownloadingImage(bool visible) {
    return visible ? Center(child: XedProgress.indicator()) : SizedBox();
  }

  void _controlDownloadingWidget(bool vissble) {
    isDownloadingImage = vissble;
    setState(() {});
  }

  void _onPickAvatar(BuildContext context) async {
    await XChooseImagePopup(
      context: context,
      hideSearchImage: true,
      onFileSelected: (file) {
        _controlDownloadingWidget(false);
        if (file != null) {
          dispatchUploadImage(file);
        }
      },
      onDownloadingFile: () {
        _controlDownloadingWidget(true);
      },
      onCompleteDownloadFile: () {
        _controlDownloadingWidget(false);
      },
      ratioX: 1.0,
      ratioY: 1.0,
      onError: (Exception value) {
        _controlDownloadingWidget(false);
        dispatchError();
      },
      preScreenName: '/',
    ).show();

    closeUntilRootScreen(context: context);
  }

  void dispatchUploadImage(File file) {
    uploadBloc.add(UploadImageEvent(file));
  }

  void dispatchError() {
    uploadBloc.add(ErrorEvent());
  }

  Widget profileSettingRow(
    Widget headerIcon,
    String text,
    Widget trailingIcon,
    Function onTap,
  ) {
    return InkWell(
      child: Container(
        height: hp(50),
        alignment: Alignment.center,
        child: Row(
          children: <Widget>[
            headerIcon,
            SizedBox(width: wp(20)),
            Text(
              text,
              style: SemiBoldTextStyle(16).copyWith(height: 1.4),
            ),
            Spacer(),
            trailingIcon ?? SizedBox(),
          ],
        ),
      ),
      onTap: () => XError.f0(onTap),
    );
  }

  Future<void> updateAvatar(
    ImageUploadedSuccess state,
    core.LoginData loginData,
  ) async {
    try {
      core.Log.debug(state.component.url);
      userProfile = await userProfileService.updateMyProfile(
        userProfile.fullName,
        userProfile.gender,
        userProfile.dob,
        state.component.url,
        userProfile.nationality,
        userProfile.nativeLanguages,
        userProfile.userSettings,
      );
      var newLoginData = loginData..userProfile = userProfile;
      await authService.updateUserProfile(newLoginData);
      setState(() {});
    } catch (ex) {
      core.Log.error((ex as core.APIException).message);
      core.Log.error((ex as core.APIException).reason);
    }
  }

  void _onLogoutPressed() {
    authBloc.add(LoggedOut());
  }
}
