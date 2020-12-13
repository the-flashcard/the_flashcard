part of 'notification_bloc.dart';

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
