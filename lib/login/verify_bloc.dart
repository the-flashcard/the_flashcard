import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/common.dart';

abstract class VerifyEvent {
  VerifyEvent([this.props = const []]);

  @override
  final List<Object> props;
}

@immutable
class VerifyState extends Equatable {
  final LoginData loginData;

  final bool isCodeValid;
  final bool isSubmitting;
  final bool isResending;
  final bool isFailure;
  final bool isSuccess;
  final bool isSent;
  final String error;

  @override
  final List<Object> props;

  VerifyState({
    this.loginData,
    @required this.isCodeValid,
    @required this.isResending,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isSent,
    @required this.isFailure,
    this.error = '',
  }) : props = ([
          loginData,
          isCodeValid,
          isResending,
          isSubmitting,
          isFailure,
          isSent,
          isSuccess,
          error
        ]);

  factory VerifyState.empty() {
    return VerifyState(
      isCodeValid: false,
      isResending: false,
      isSubmitting: false,
      isSent: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory VerifyState.loading() {
    return VerifyState(
      isCodeValid: true,
      isResending: false,
      isSubmitting: true,
      isSent: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory VerifyState.resending() {
    return VerifyState(
      isCodeValid: true,
      isResending: true,
      isSubmitting: false,
      isSent: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory VerifyState.failure(String error) {
    return VerifyState(
        isCodeValid: true,
        isResending: false,
        isSent: false,
        isSubmitting: false,
        isSuccess: false,
        isFailure: true,
        error: error);
  }

  factory VerifyState.success(LoginData loginData) {
    return VerifyState(
      loginData: loginData,
      isCodeValid: true,
      isResending: false,
      isSent: false,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  VerifyState copyWith({
    LoginData loginData,
    bool isCodeValid,
    bool isResending,
    bool isSubmitting,
    bool isSent,
    bool isSuccess,
    bool isFailure,
    String error,
  }) {
    return VerifyState(
      loginData: loginData ?? this.loginData,
      isCodeValid: isCodeValid ?? this.isCodeValid,
      isResending: isResending ?? this.isResending,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSent: isSent ?? this.isSent,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return '''VerifyState {
      isCodeValid: $isCodeValid,
      isResending: $isResending,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}

class VerifyCodeCompleted extends VerifyEvent {
  @override
  String toString() => this.runtimeType.toString();
}

class VerifyCodeUnCompleted extends VerifyEvent {
  @override
  String toString() => this.runtimeType.toString();
}

class ResendCodeEvent extends VerifyEvent {
  final String email;

  ResendCodeEvent({
    @required this.email,
  }) : super([email]);

  @override
  String toString() => this.runtimeType.toString();
}

class VerifyPressedEvent extends VerifyEvent {
  final String email;
  final String code;

  VerifyPressedEvent({
    @required this.email,
    @required this.code,
  }) : super([email, code]);

  @override
  String toString() => 'VerifyPressed { email: $email, code: $code }';
}

class VerifyBloc extends Bloc<VerifyEvent, VerifyState> {
  final AuthService authService = DI.get(AuthService);
  final AuthenticationBloc authenticationBloc;

  VerifyBloc({
    @required this.authenticationBloc,
  });
  @override
  VerifyState get initialState => VerifyState.empty();

  @override
  Stream<VerifyState> mapEventToState(VerifyEvent event) async* {
    if (event is VerifyCodeCompleted) {
      yield* onCodeCompleted(true);
    } else if (event is VerifyCodeUnCompleted) {
      yield* onCodeCompleted(false);
    } else if (event is VerifyPressedEvent) {
      yield* handleVerify(event);
    } else if (event is ResendCodeEvent) {
      yield* handleSendVerifyCode(event);
    }
  }

  Stream<VerifyState> onCodeCompleted(bool isCompleted) async* {
    yield state.copyWith(
      isCodeValid: isCompleted,
      isFailure: false,
      error: '',
    );
  }

  Stream<VerifyState> handleVerify(VerifyPressedEvent event) async* {
    try {
      yield VerifyState.loading();
      LoginData loginData =
          await authService.verifyCode(event.email, event.code);
      yield state.copyWith(
          loginData: loginData,
          isResending: false,
          isSubmitting: false,
          isSent: false,
          isSuccess: true,
          isFailure: false);
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.QuotaExceed:
          yield VerifyState.failure(Config.getString("msg_limit_reached"));
          break;
        case ApiErrorReasons.VerificationCodeInvalid:
          yield VerifyState.failure(Config.getString("msg_code_incorrect"));
          break;
        default:
          yield VerifyState.failure('${e.reason} - ${e.message}');
          break;
      }
    } catch (e) {
      yield VerifyState.failure(e.message);
    }
  }

  Stream<VerifyState> handleSendVerifyCode(ResendCodeEvent event) async* {
    try {
      yield VerifyState.resending();
      bool sentStatus = await authService.sendVerifyCode(event.email);
      if (sentStatus)
        yield state.copyWith(
            isResending: false,
            isSubmitting: false,
            isSent: true,
            isSuccess: false,
            isFailure: false);
      else
        yield VerifyState.failure(Config.getString("msg_cant_resend_code"));
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.QuotaExceed:
          yield VerifyState.failure(Config.getString("msg_limit_reached"));
          break;
        case ApiErrorReasons.VerificationCodeInvalid:
          yield VerifyState.failure(Config.getString("msg_code_incorrect"));
          break;
        default:
          yield VerifyState.failure('${e.reason} - ${e.message}');
      }
    } catch (e) {
      yield VerifyState.failure(e.message);
    }
  }
}
