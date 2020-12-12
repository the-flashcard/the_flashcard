import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart';

class NotificationType {
  static final int ERROR = 0;
  static final int SUCCESS = 1;
}

abstract class NotificationEvent {}

class ErrorNotification extends NotificationEvent {
  dynamic error;

  ErrorNotification(this.error);
}

class AddNotification extends NotificationEvent {
  int notificationType;
  String mesage;

  AddNotification(this.notificationType, this.mesage);
}

class HideNotification extends NotificationEvent {}

abstract class NotificationState extends Equatable {
  final Color color;
  final String message;

  NotificationState(
    this.color,
    this.message,
  );

  bool get hasNotification => message != null;

  NotificationState hide() {
    return NotificationHide();
  }

  NotificationState show({Color color, String message}) {
    return NotificationShow(
      color ?? this.color,
      message ?? this.message,
    );
  }

  NotificationState copyWith({
    String message,
  });

  @override
  List get props => [color?.value, this.message];
}

class NotificationHide extends NotificationState {
  NotificationHide()
      : super(
          Colors.green,
          "",
        );

  NotificationState copyWith({
    Color color,
    String message,
  }) {
    return NotificationHide();
  }
}

class NotificationShow extends NotificationState {
  NotificationShow(Color color, String message)
      : super(
          color,
          message,
        );

  NotificationState copyWith({Color color, String message}) {
    return NotificationShow(
      color ?? color,
      message ?? this.message,
    );
  }
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  @override
  NotificationState get initialState => NotificationHide();

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    switch (event.runtimeType) {
      case HideNotification:
        yield* _hide();
        break;
      case AddNotification:
        yield* _show(event);
        break;
      case ErrorNotification:
        yield* _error(event);
        break;
    }
  }

  Stream<NotificationState> _hide() async* {
    yield state.hide();
  }

  Stream<NotificationState> _show(AddNotification event) async* {
    yield state.show(
      color: getColor(event.notificationType),
      message: event.mesage,
    );
  }

  Stream<NotificationState> _error(ErrorNotification event) async* {
    var ex = event.error;
    if (ex is APIException) {
      switch (ex.reason) {
        case ApiErrorReasons.NotAuthenticated:
          yield state.show(
            color: getColor(NotificationType.ERROR),
            message: Config.getString('msg_not_authenticated'),
          );
          break;
        case ApiErrorReasons.NoConnectionError:
          yield state.show(
            color: getColor(NotificationType.ERROR),
            message: Config.getString('msg_no_connection'),
          );
          break;
        case ApiErrorReasons.OutOfQuotaError:
          yield state.show(
            color: getColor(NotificationType.ERROR),
            message: Config.getString('msg_out_of_translation_quota'),
          );
          break;
        default:
          yield state.show(
            color: getColor(NotificationType.ERROR),
            message: Config.getString('msg_error_try_again'),
          );
      }
    } else {
      yield state.show(
        color: getColor(NotificationType.ERROR),
        message: Config.getString('msg_error_try_again'),
      );
    }
  }

  Color getColor(int notificationType) {
    if (notificationType == NotificationType.SUCCESS)
      return Colors.green;
    else if (notificationType == NotificationType.ERROR)
      return Colors.red;
    else
      return Colors.amberAccent;
  }
}
