part of 'authentication_bloc.dart';

abstract class AuthenticationState {
  @override
  String toString() => "$runtimeType";
}

class AuthenticationUninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final LoginData loginData;

  Authenticated(this.loginData);
}

class Unauthenticated extends AuthenticationState {}

class Authenticating extends AuthenticationState {}

class FirstRunState extends AuthenticationState {}
