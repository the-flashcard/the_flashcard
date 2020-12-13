import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/common.dart';

part 'forget_password_event.dart';
part 'forget_password_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  AuthenticationBloc authenticationBloc = DI.get(AuthenticationBloc);
  AuthService authService = DI.get(AuthService);

  String email;
  String token;

  ForgetPasswordBloc()
      : email = '',
        token = '';
  @override
  ForgetPasswordState get initialState => ForgetPasswordState().init();

  @override
  Stream<ForgetPasswordState> mapEventToState(
    ForgetPasswordEvent event,
  ) async* {
    switch (event.runtimeType) {
      case TypingEmail:
        yield* _handleTypingEmail(event);
        break;
      case SubmitEmail:
        yield* _handleSumitEmail(event);
        break;
      case SubmitCode:
        yield* _handleSumitCode(event);
        break;
      default:
    }
  }

  Stream<ForgetPasswordState> _handleTypingEmail(TypingEmail event) async* {
    yield EmailUtils.isValidEmail(event.email)
        ? state.success()
        : state.failure('', isEmailValid: false);
  }

  Stream<ForgetPasswordState> _handleSumitEmail(SubmitEmail event) async* {
    try {
      email = event.email;
      yield state.success(nextStep: true);
      await authService.forgetPassword(event.email);
    } on APIException catch (e) {
      String errorMessage = '';
      switch (e.reason) {
        case ApiErrorReasons.QuotaExceed:
          errorMessage = Config.getString("msg_limit_reached");
          break;
        case ApiErrorReasons.EmailNotExisted:
          errorMessage = Config.getString("msg_email_not_existed");
          break;
        default:
          errorMessage = '${e.reason} - ${e.message}';
      }
      yield state.failure(errorMessage);
    } catch (ex) {
      Log.error(ex);
      yield state.failure(Config.getString('msg_something_went_wrong'));
    }
  }

  Stream<ForgetPasswordState> _handleSumitCode(SubmitCode event) async* {
    try {
      yield state.loading();
      token = await authService.verifyForgetPassword(email, event.code);
      yield state.success(nextStep: true);
    } on APIException catch (e) {
      String errorMessage = '';
      switch (e.reason) {
        case ApiErrorReasons.QuotaExceed:
          errorMessage = Config.getString("msg_limit_reached");
          break;
        case ApiErrorReasons.VerificationCodeInvalid:
          errorMessage = Config.getString("msg_code_invalid");
          break;
        default:
          errorMessage = '${e.reason} - ${e.message}';
      }
      yield state.failure(errorMessage);
    } catch (ex) {
      Log.error(ex);
      yield state.failure(Config.getString('msg_something_went_wrong'));
    }
  }
}
