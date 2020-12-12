import 'package:flutter/material.dart';

class XComponentEditController {
  final ValueNotifier<void> _controller = ValueNotifier(() {});
  final ValueNotifier<void> _resetController = ValueNotifier(() {});

  void addListeners({
    Function onEdit,
    Function onReset,
  }) {
    _controller.addListener(() {
      if (onEdit != null) onEdit();
    });

    _resetController.addListener(() {
      if (onReset != null) onReset();
    });
  }

  void edit() {
    _controller.value = () {};
  }

  void reset() {
    _resetController.value = () {};
  }

  void dispose() {
    _controller?.dispose();
    _resetController?.dispose();
  }
}
