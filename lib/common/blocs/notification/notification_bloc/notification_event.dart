part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class ErrorNotification extends NotificationEvent {
  dynamic error;

  ErrorNotification(this.error);
}

class AddNotification extends NotificationEvent {
  int notificationType;
  String message;

  AddNotification(this.notificationType, this.message);
}

class HideNotification extends NotificationEvent {}
