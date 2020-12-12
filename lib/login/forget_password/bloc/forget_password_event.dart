part of 'forget_password_bloc.dart';

abstract class ForgetPasswordEvent {
  @override
  String toString() {
    return '$runtimeType';
  }
}

class TypingEmail extends ForgetPasswordEvent {
  final String email;

  TypingEmail(this.email);
}

class SubmitEmail extends ForgetPasswordEvent {
  final String email;

  SubmitEmail(this.email);
}

class SubmitCode extends ForgetPasswordEvent {
  final String code;

  SubmitCode(this.code);
}
