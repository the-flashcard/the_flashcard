import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';

@immutable
class RegisterState extends Equatable {
  final bool isFullNameValid;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isFailure;
  final bool isSuccess;

  final UserProfile profile;
  final String error;

  bool get isFormValid => isFullNameValid && isEmailValid && isPasswordValid;

  String get fullNameErrorText {
    if (!isFullNameValid)
      return Config.getString("msg_fullname_invalid");
    else
      return null;
  }

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

  RegisterState({
    @required this.isFullNameValid,
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
    this.profile,
    this.error = '',
  }) : props = ([
          isFullNameValid,
          isEmailValid,
          isPasswordValid,
          isSubmitting,
          isFailure,
          isSuccess,
          profile,
          error
        ]);

  factory RegisterState.empty() {
    return RegisterState(
      isFullNameValid: true,
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.loading() {
    return RegisterState(
      isFullNameValid: true,
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.failure(String error) {
    return RegisterState(
        isFullNameValid: true,
        isEmailValid: true,
        isPasswordValid: true,
        isSubmitting: false,
        isSuccess: false,
        isFailure: true,
        error: error);
  }

  factory RegisterState.success(UserProfile profile) {
    return RegisterState(
      isFullNameValid: true,
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      profile: profile,
      isFailure: false,
    );
  }

  RegisterState update({
    bool isFullNameValid,
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      isFullNameValid: isFullNameValid ?? this.isFullNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  RegisterState copyWith({
    bool isFullNameValid,
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
    String error,
  }) {
    return RegisterState(
      isFullNameValid: isFullNameValid ?? this.isFullNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return '''LoginState {
      isFullNameValid: $isFullNameValid,
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}

abstract class RegisterEvent extends Equatable {
  RegisterEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class FullNameChanged extends RegisterEvent {
  final String fullName;

  FullNameChanged(this.fullName) : super([fullName]);

  @override
  String toString() => 'EmailChanged';
}

class EmailChanged extends RegisterEvent {
  final String email;

  EmailChanged(this.email) : super([email]);

  @override
  String toString() => 'EmailChanged';
}

class PasswordChanged extends RegisterEvent {
  final String password;

  PasswordChanged(this.password) : super([password]);

  @override
  String toString() => 'PasswordChanged';
}

class RegisterPressed extends RegisterEvent {
  final String fullName;
  final String email;
  final String password;

  RegisterPressed({
    @required this.fullName,
    @required this.email,
    @required this.password,
  }) : super([email, password]);

  @override
  String toString() =>
      'RegisterPressed { username: $email, password: $password }';
}

class FacebookPressed extends RegisterEvent {
  final String token;
  final String userId;

  FacebookPressed({
    @required this.token,
    @required this.userId,
  });

  @override
  String toString() => 'LoginPressed { token: $token, userId: $userId }';
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService authService = DI.get(AuthService);
  final AuthenticationBloc authenticationBloc;

  RegisterBloc({
    @required this.authenticationBloc,
  });

  @override
  RegisterState get initialState => RegisterState.empty();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    switch (event.runtimeType) {
      case FullNameChanged:
        yield* validateFullName(event);
        break;
      case EmailChanged:
        yield* validateEmail(event);
        break;
      case PasswordChanged:
        yield* validatePassword(event);
        break;
      case RegisterPressed:
        yield* handleRegisterAndLogin(event);
        break;
      case FacebookPressed:
        yield* handleFacebookLogin(event);
        break;
    }
  }

  Stream<RegisterState> validateFullName(FullNameChanged event) async* {
    yield state.update(
      isFullNameValid:
          event.fullName != null && event.fullName.trim().isNotEmpty,
    );
  }

  Stream<RegisterState> validateEmail(EmailChanged event) async* {
    yield state.update(
      isEmailValid: EmailUtils.isValidEmail(event.email),
    );
  }

  Stream<RegisterState> validatePassword(PasswordChanged event) async* {
    yield state.update(
      isPasswordValid: EmailUtils.isValidPassword(event.password),
    );
  }

  Stream<RegisterState> handleRegister(RegisterPressed event) async* {
    yield RegisterState.loading();
    try {
      final isFullNameValid =
          event.fullName != null && event.fullName.trim().isNotEmpty;
      final isEmailValid = EmailUtils.isValidEmail(event.email);
      final isPasswordValid = EmailUtils.isValidPassword(event.password);

      if (!isFullNameValid || !isEmailValid || !isPasswordValid) {
        yield state.copyWith(
          isFullNameValid: isFullNameValid,
          isEmailValid: isEmailValid,
          isPasswordValid: isPasswordValid,
          isFailure: true,
          error: Config.getString("msg_check_profile"),
        );
      } else {
        RegistrationData registerData = await authService.register(
            event.email, event.password, event.fullName);
        yield RegisterState.success(registerData.userProfile);
      }
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.EmailExisted:
          yield RegisterState.failure(Config.getString("msg_email_existed"));
          break;
        default:
          yield RegisterState.failure('${e.reason} - ${e.message}');
      }
    } catch (e) {
      yield RegisterState.failure(e.message);
    }
  }

  Stream<RegisterState> handleRegisterAndLogin(RegisterPressed event) async* {
    yield RegisterState.loading();
    try {
      final isFullNameValid =
          event.fullName != null && event.fullName.trim().isNotEmpty;
      final isEmailValid = EmailUtils.isValidEmail(event.email);
      final isPasswordValid = EmailUtils.isValidPassword(event.password);

      if (!isFullNameValid || !isEmailValid || !isPasswordValid) {
        yield state.copyWith(
          isFullNameValid: isFullNameValid,
          isEmailValid: isEmailValid,
          isPasswordValid: isPasswordValid,
          isFailure: true,
          error: Config.getString("msg_check_profile"),
        );
      } else {
        LoginData loginData = await authService.registerAndLogin(
            event.email, event.password, event.fullName);
        AuthenticationBloc authenticationBloc = DI.get(AuthenticationBloc);
        authenticationBloc.add(LoggedIn(loginData));
        yield RegisterState.success(loginData.userProfile);
      }
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.EmailExisted:
          yield RegisterState.failure(Config.getString("msg_email_existed"));
          break;
        default:
          yield RegisterState.failure('${e.reason} - ${e.message}');
      }
    } catch (e) {
      yield RegisterState.failure(e.message);
    }
  }

  Stream<RegisterState> handleFacebookLogin(FacebookPressed event) async* {
    try {
      yield RegisterState.loading();
      final String oauthType = 'facebook';
      LoginData loginData = await authService.loginWithOAuth(
          oauthType, event.userId, event.token);
      authenticationBloc.add(LoggedIn(loginData));
      yield RegisterState.success(loginData.userProfile);
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.InvalidCredentials:
          yield RegisterState.failure(Config.getString("msg_check_login"));
          break;
        default:
          yield RegisterState.failure('${e.reason} - ${e.message}');
          break;
      }
    } catch (e) {
      yield RegisterState.failure(e.message);
    }
  }
}
