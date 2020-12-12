import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;

enum ScrollControllerCardSideMode { OnlyFront, OnlyBack, Both }

class ScrollControllerCardSide {
  final List<ScrollController> _fronts;
  final ScrollController _back;

  ScrollControllerCardSide()
      : _fronts = <ScrollController>[],
        _back = ScrollController();

  ScrollController getController(bool isFront, int sideIndex) {
    if (isFront) {
      return sideIndex < _fronts.length
          ? _fronts[sideIndex]
          : ScrollController();
    } else {
      return getBackController();
    }
  }

  ScrollController getBackController() => _back;

  void initControllers(int numberController) {
    _fronts.addAll(List.generate(numberController, (i) => ScrollController()));
    core.Log.debug(_fronts.length);
  }

  void addControllerFront() {
    _fronts.add(ScrollController());
  }

  void removeControllerFront(int sideIndex) {
    _fronts.removeAt(sideIndex);
  }

  void moveToBottom(bool isFront, int sideIndex) {
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (isFront) {
        if (sideIndex < _fronts.length)
          _fronts[sideIndex].animateTo(
            _fronts[sideIndex].position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
      } else
        _back.animateTo(
          _back.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
    }).catchError((onError) => core.Log.debug(onError));
  }
}
