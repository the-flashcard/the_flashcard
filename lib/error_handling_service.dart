import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart';

class ErrorHandlingService {
  List<ErrorHandler> handlers;
  ErrorHandlingService(this.handlers);

  void handleDioError(DioError error) {
    var firstHandler = handlers.firstWhere(
      (handler) => handler.canHandle(error),
      orElse: () => null,
    );
    if (firstHandler != null) {
      firstHandler.handle();
    }
  }
}

abstract class ErrorHandler {
  BuildContext context;
  ErrorHandler(this.context);
  bool canHandle(DioError error);
  void handle();
}

class SessionExpiredErrorHandler extends ErrorHandler {
  SessionExpiredErrorHandler(BuildContext context) : super(context);

  @override
  bool canHandle(DioError ex) {
    var error = APIException.from(ex);

    return error.reason == ApiErrorReasons.NotAuthenticated;
  }

  @override
  void handle() {
    // var authenBloc = BlocProvider.of<AuthenticationBloc>(context);
    // authenBloc.add(AppStarted());
    // DriverKey.navigatorGlobalKey.currentState
    //     .popUntil(ModalRoute.withName('/'));
  }
}
