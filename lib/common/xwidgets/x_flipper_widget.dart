import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flip_view/flutter_flip_view.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/xerror.dart';

class FlipController {
  final ValueNotifier<void> _controller = ValueNotifier(() {});
  final ValueNotifier<void> _resetController = ValueNotifier(() {});

  FlipController({bool isFront = true});

  void addListeners({
    Function onSwipe,
    Function onReset,
  }) {
    _controller.addListener(() {
      if (onSwipe != null) onSwipe();
    });

    _resetController.addListener(() {
      if (onReset != null) onReset();
    });
  }

  void flip() {
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

class XFlipperWidget extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFront;
  final FlipController flipController;
  final ValueChanged<bool> onFlipped;
  final bool tapToFlipEnable;

  XFlipperWidget({
    @required this.front,
    @required this.back,
    this.isFront = true,
    this.flipController,
    this.onFlipped,
    this.tapToFlipEnable = false,
  });

  @override
  _XFlipperWidgetState createState() => _XFlipperWidgetState();
}

class _XFlipperWidgetState extends State<XFlipperWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _curvedAnimation;
  AnimationController _animationController;
  bool isFront;

  @override
  void initState() {
    super.initState();
    isFront = widget.isFront ?? false;

    if (_animationController == null) {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 700),
      );

      _curvedAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flipController != null)
      widget.flipController.addListeners(
        onSwipe: _flip,
        onReset: _reset,
      );

    Widget flipView = FlipView(
      animationController: _curvedAnimation,
      front: widget.front,
      back: widget.back,
    );
    return widget.tapToFlipEnable
        ? GestureDetector(
            onTap: () => XError.f0(() {
              if (widget.tapToFlipEnable && _flip != null) _flip();
            }),
            child: flipView,
          )
        : flipView;
  }

  void _reset() {
    Log.debug("current flip: ${this.isFront}");
    if (_animationController.isAnimating)
      return;
    else if (this.mounted) {
      if (!this.isFront) {
        _animationController.reverse();
        _flipAnimation(!this.isFront);
      }
    }
  }

  void _flip() {
    Log.debug("current flip: ${this.isFront}");
    if (_animationController.isAnimating)
      return;
    else if (this.mounted) {
      if (this.isFront) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      _flipAnimation(!this.isFront);
    }
  }

  void _flipAnimation(bool isFront) {
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        this.isFront = isFront;
        if (widget.onFlipped != null) {
          widget.onFlipped(isFront);
        }
      });
    });
  }
}
