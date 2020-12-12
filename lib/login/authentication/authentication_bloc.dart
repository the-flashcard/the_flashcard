import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';
import 'package:the_flashcard/module/bloc_module.dart';
import 'package:the_flashcard/module/dev_module.dart';
import 'package:the_flashcard/module/flare_caching_module.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    switch (event.runtimeType) {
      case AppStarted:
        yield* _appStart(event);
        break;
      case LoggedIn:
        yield* _onLoginSuccess(event);
        break;
      case LoggedOut:
        yield* _handleLogout(event);
        break;
    }
  }

  Stream<AuthenticationState> _appStart(AppStarted event) async* {
    try {
      yield Authenticating();
      await _initDI(this);
      UserSessionRepository repository = DI.get(UserSessionRepository);
      // yield AuthenticationUninitialized();

      final bool isFirstRun = await repository.isFirstRun();
      if (isFirstRun) {
        yield FirstRunState();
      } else {
        AuthService authService = DI.get(AuthService);
        var loginData = await authService.checkToken();
        sleep(Duration(seconds: 1));
        if (loginData != null) {
          yield Authenticated(loginData);
        } else {
          yield Unauthenticated();
        }
      }
    } catch (ex) {
      yield Unauthenticated();
    }
  }

  Future _initDI(AuthenticationBloc bloc) async {
    Config.init(kReleaseMode ? Mode.Production : Mode.Debug);
    var hiveStorage = HiveStorage();
    await hiveStorage.init();
    var mainModule = DevModule(hiveStorage);
    DI.init([mainModule, BlocModule(bloc), FlareCachingModule()]);
  }

  Stream<AuthenticationState> _onLoginSuccess(LoggedIn event) async* {
    yield Authenticating();
    PageNavigatorBloc navigatorBloc = DI.get(PageNavigatorBloc);
    navigatorBloc.add(GotoHomePage());
    yield Authenticated(event.loginData);
  }

  Stream<AuthenticationState> _handleLogout(LoggedOut event) async* {
    yield Authenticating();
    AuthService authService = DI.get(AuthService);
    await authService.logout();
    yield Unauthenticated();
    DriverKey.navigatorGlobalKey.currentState
        .popUntil(ModalRoute.withName('/'));
  }
}
