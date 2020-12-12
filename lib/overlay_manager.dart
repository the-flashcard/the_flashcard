import 'package:flutter/material.dart';

class OverLayManger {
  OverlayEntry _currentEntry;

  bool get canDisPlay => _currentEntry == null;

  void display(
    BuildContext context,
    Widget overLay, {
    bool forceDisplay = false,
  }) {
    if (forceDisplay) {
      Overlay.of(context).rearrange([]);
    }
    _currentEntry = OverlayEntry(builder: (_) => overLay);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(_currentEntry);
    });
  }

  void remove() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
