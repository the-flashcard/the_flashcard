part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {
  @override
  String toString() => "$runtimeType";
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final LoginData loginData;

  LoggedIn(this.loginData);
}

class LoggedOut extends AuthenticationEvent {}
