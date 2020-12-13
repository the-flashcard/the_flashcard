import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_flashcard/common/common.dart';

class NotificationReceiver extends StatelessWidget {
  final Widget child;
  NotificationReceiver({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      bloc: DI.get(NotificationBloc),
      listener: (context, notificationState) {
        if (notificationState is NotificationShow) {
          XState.showSnakeBar(
              context, notificationState.message, notificationState.color);
        }
      },
      child: child,
    );
  }
}
