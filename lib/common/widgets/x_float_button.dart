import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/resources/xed_shadows.dart';
import 'package:the_flashcard/xerror.dart';
import 'package:vector_math/vector_math.dart' show radians;

abstract class OnFloatButtonCallBack {
  void onFloatingOpen(int index);

  void onFloatingMoveUp();

  void onFloatingMoveDown();

  void onFloatingEdit();

  void onFloatingDelete();

  void onFloatingClose();
}

class XFloatButton {
  AnimationController controller;
  OverlayEntry _overlayEntry;
  bool _isShowing = false;
  Animation<double> _translation;
  Animation<double> _rotation;
  final OnFloatButtonCallBack callBack;

  XFloatButton(this.controller, this.callBack) {
    _translation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    _rotation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.7, curve: Curves.decelerate),
      ),
    );
  }

  OverlayEntry _buildOverlayEntry({Offset location}) {
    if (location == null) location = Offset(0, 0);
    return OverlayEntry(builder: (_) {
      return AnimatedBuilder(
          animation: controller,
          builder: (context, widget) {
            double width = MediaQuery.of(context).size.width;
            return Transform.rotate(
              angle: radians(_rotation.value),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => XError.f0(closeButton),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: XedColors.transparent,
                    ),
                  ),
                  _isShowing
                      ? _buildButton(
                          _translation,
                          location.dx > width / 2 ? -225 : 0,
                          SvgPicture.asset(
                            Assets.icDelete,
                            color: XedColors.black,
                          ),
                          location,
                          () => _onDeletePressed())
                      : SizedBox(),
                  _isShowing
                      ? _buildButton(
                          _translation,
                          location.dx > width / 2 ? -180 : -45,
                          SvgPicture.asset(
                            Assets.icEdit,
                            color: XedColors.black,
                          ),
                          location,
                          () => _onEditPressed())
                      : SizedBox(),
                  _isShowing
                      ? _buildButton(
                          _translation,
                          -90,
                          SvgPicture.asset(
                            Assets.icMoveDown,
                            color: XedColors.black,
                          ),
                          location,
                          () => _onDownPressed())
                      : SizedBox(),
                  _isShowing
                      ? _buildButton(
                          _translation,
                          -135,
                          SvgPicture.asset(
                            Assets.icMoveUp,
                            color: XedColors.black,
                          ),
                          location,
                          () => _onUpPressed(),
                        )
                      : SizedBox(),
                  Positioned(
                      left: location.dx,
                      top: location.dy,
                      child: Container(
                        height: hp(55),
                        width: hp(55),
                        decoration: BoxDecoration(
                          color: XedColors.white,
                          boxShadow: [XedShadows.shadow4],
                          shape: BoxShape.circle,
                        ),
                        child: FlatButton(
                          shape: CircleBorder(),
                          child: Icon(Icons.close),
                          onPressed: () => XError.f0(_onClosePressed),
                        ),
                      ))
                ],
              ),
            );
          });
    });
  }

  Widget _buildButton(
    Animation<double> translation,
    double angle,
    Widget icon,
    Offset position,
    VoidCallback onPress,
  ) {
    final double rad = radians(angle);
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Transform(
          transform: Matrix4.identity()
            ..translate(
                (translation.value) * cos(rad), (translation.value) * sin(rad)),
          child: Container(
            height: hp(55),
            width: hp(55),
            decoration: BoxDecoration(
              color: XedColors.white,
              shape: BoxShape.circle,
              boxShadow: [XedShadows.shadow4],
            ),
            child: FlatButton(
              shape: CircleBorder(),
              child: icon,
              onPressed: onPress != null ? () => XError.f0(onPress) : null,
            ),
          )),
    );
  }

  void _onOpen(int index) {
    callBack?.onFloatingOpen(index);
  }

  void _onUpPressed() {
    callBack?.onFloatingMoveUp();
  }

  void _onDownPressed() {
    callBack?.onFloatingMoveDown();
  }

  void _onDeletePressed() {
    callBack?.onFloatingDelete();
    _onClosePressed();
  }

  void _onEditPressed() {
    if (_isShowing) closeButton();
    callBack?.onFloatingEdit();
  }

  void _onClosePressed() {
    if (_isShowing) closeButton();
    callBack?.onFloatingClose();
  }

  void show(BuildContext context, int index, Offset position) {
    if (!_isShowing) {
      _overlayEntry = _buildOverlayEntry(location: position);
      Overlay.of(context).insert(_overlayEntry);
      controller.forward();
      _isShowing = true;

      _onOpen(index);
    }
  }

  void closeButton() {
    if (_isShowing == true) {
      controller.reverse().whenComplete(() {
        _isShowing = false;
        _overlayEntry?.remove();
      });
    }
  }
}
