import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/common.dart';

@immutable
class LoginState extends Equatable {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isFailure;
  final bool isVerificationRequired;
  final bool isSuccess;

  final String email;
  final String error;

  bool get isFormValid => isEmailValid && isPasswordValid;

  String get emailErrorText {
    if (!isEmailValid)
      return Config.getString("msg_email_invalid");
    else
      return null;
  }

  String get passwordErrorText {
    if (!isPasswordValid) {
      return Config.getString("msg_password_rule");
      //return "Minimum 6 characters and contain numbers and/or letters only.";
    } else {
      return null;
    }
  }

  @override
  final List<Object> props;

  LoginState({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
    this.email = '',
    this.error = '',
    this.isVerificationRequired = false,
  }) : props = ([
          isEmailValid,
          isPasswordValid,
          isSubmitting,
          isFailure,
          isVerificationRequired,
          isSuccess,
          email,
          error
        ]);

  factory LoginState.empty() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory LoginState.failure(String error) {
    return LoginState(
        isEmailValid: true,
        isPasswordValid: true,
        isSubmitting: false,
        isSuccess: false,
        isFailure: true,
        error: error);
  }

  factory LoginState.verificationRequired(String email) {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
      email: email,
      isVerificationRequired: true,
    );
  }

  factory LoginState.success(String email) {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      email: email,
      isFailure: false,
    );
  }

  LoginState update({bool isEmailValid, bool isPasswordValid}) {
    return copyWith(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  LoginState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
    bool isVerificationRequired,
    String error,
  }) {
    return LoginState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      error: error ?? this.error,
      isVerificationRequired:
          isVerificationRequired ?? this.isVerificationRequired,
    );
  }

  @override
  String toString() {
    return '''LoginState {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
      isVerificationRequired: $isVerificationRequired,
    }''';
  }
}

abstract class LoginEvent extends Equatable {
  LoginEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class EmailChanged extends LoginEvent {
  final String email;

  EmailChanged(this.email) : super([email]);

  @override
  String toString() => 'EmailChanged';
}

class PasswordChanged extends LoginEvent {
  final String password;

  PasswordChanged(this.password) : super([password]);

  @override
  String toString() => 'PasswordChanged';
}

class LoginPressed extends LoginEvent {
  final String email;
  final String password;

  LoginPressed({
    @required this.email,
    @required this.password,
  }) : super([email, password]);

  @override
  String toString() => 'LoginPressed { username: $email, password: $password }';
}

class FacebookPressed extends LoginEvent {
  final String token;
  final String userId;

  FacebookPressed({
    @required this.token,
    @required this.userId,
  });

  @override
  String toString() => 'LoginPressed { token: $token, userId: $userId }';
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.empty());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    switch (event.runtimeType) {
      case EmailChanged:
        yield* validateEmail(event);
        break;
      case PasswordChanged:
        yield* validatePassword(event);
        break;
      case LoginPressed:
        yield* handleLogin(event);
        break;
      case FacebookPressed:
        yield* handleFacebookLogin(event);
        break;
    }
  }

  Stream<LoginState> validateEmail(EmailChanged event) async* {
    yield state.update(
      isEmailValid: EmailUtils.isValidEmail(event.email),
    );
  }

  Stream<LoginState> validatePassword(PasswordChanged event) async* {
    yield state.update(
      isPasswordValid: EmailUtils.isValidPassword(event.password),
    );
  }

  Stream<LoginState> handleLogin(LoginPressed event) async* {
    try {
      yield LoginState.loading();
      final isEmailValid = EmailUtils.isValidEmail(event.email);
      final isPasswordValid = EmailUtils.isValidPassword(event.password);
      if (!isEmailValid || !isPasswordValid) {
        yield state.copyWith(
            isEmailValid: isEmailValid,
            isPasswordValid: isPasswordValid,
            isFailure: true,
            error: Config.getString("msg_check_login"));
      } else {
        AuthService authService = DI.get(AuthService);
        LoginData loginData = await authService.login(
            event.email?.trim(), event.password?.trim(), true);
        AuthenticationBloc authenticationBloc = DI.get(AuthenticationBloc);
        authenticationBloc.add(LoggedIn(loginData));
        yield LoginState.success(event.email);
      }
    } on APIException catch (e) {
      Log.error(e);
      switch (e.reason) {
        case ApiErrorReasons.EmailVerificationRequired:
          var newState = LoginState.verificationRequired(event.email);
          yield newState;
          yield newState.copyWith(isVerificationRequired: false);
          break;
        case ApiErrorReasons.InvalidCredentials:
          yield LoginState.failure(Config.getString("msg_check_login"));
          break;
        default:
          yield LoginState.failure('${e.reason} - ${e.message}');
          break;
      }
    } catch (e) {
      yield LoginState.failure(e.message);
    }
  }

  Stream<LoginState> handleFacebookLogin(FacebookPressed event) async* {
    try {
      yield LoginState.loading();
      final String oauthType = 'facebook';
      AuthService authService = DI.get(AuthService);
      LoginData loginData = await authService.loginWithOAuth(
          oauthType, event.userId, event.token);
      AuthenticationBloc authenticationBloc = DI.get(AuthenticationBloc);
      authenticationBloc.add(LoggedIn(loginData));
      yield LoginState.success(loginData.userProfile.email);
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.InvalidCredentials:
          yield LoginState.failure(Config.getString("msg_check_login"));
          break;
        default:
          yield LoginState.failure('${e.reason} - ${e.message}');
          break;
      }
    } catch (e) {
      yield LoginState.failure(e.message);
    }
  }
}
