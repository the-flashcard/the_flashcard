part of 'forget_password_bloc.dart';

class ForgetPasswordState {
  final bool isLoading;
  final bool isFailure;
  final bool isSuccess;
  final bool nextStep;
  final String errorMessage;
  final bool isEmailValid;

  ForgetPasswordState({
    this.isLoading,
    this.isFailure,
    this.isSuccess,
    this.errorMessage,
    this.nextStep,
    this.isEmailValid,
  });

  ForgetPasswordState init() {
    return ForgetPasswordState(
      isLoading: false,
      isFailure: true,
      isSuccess: false,
      nextStep: false,
      isEmailValid: true,
      errorMessage: '',
    );
  }

  ForgetPasswordState loading() {
    return ForgetPasswordState(
      isSuccess: false,
      isFailure: false,
      errorMessage: '',
      isLoading: true,
      isEmailValid: true,
      nextStep: false,
    );
  }

  ForgetPasswordState success({bool nextStep = false}) {
    return ForgetPasswordState(
      isSuccess: true,
      isLoading: false,
      isFailure: false,
      errorMessage: '',
      nextStep: nextStep,
      isEmailValid: true,
    );
  }

  ForgetPasswordState failure(String message, {bool isEmailValid = true}) {
    return ForgetPasswordState(
      isSuccess: false,
      isLoading: false,
      isFailure: true,
      errorMessage: message,
      isEmailValid: isEmailValid,
    );
  }
}
