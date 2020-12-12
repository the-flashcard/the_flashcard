import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_view/flutter_flip_view.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/environment/constants.dart' as cons;
import 'package:the_flashcard/xerror.dart';

class FlipCardWidget extends StatefulWidget {
  final List<Widget> front;
  final List<Widget> back;
  final String frontText;
  final String backText;
  final List<VoidCallback> listener;
  final ValueChanged<bool> onFlipped;
  final bool editable;
  final bool isTapFlip;
  final int index;
  final EdgeInsets padding;
  final EdgeInsets margin;

  FlipCardWidget({
    this.front = const <Widget>[],
    this.back = const <Widget>[],
    this.listener,
    this.onFlipped,
    this.frontText = '',
    this.backText = 'Answer',
    this.isTapFlip = false,
    @required this.editable,
    this.index = 0,
    this.padding = const EdgeInsets.only(top: 1),
    this.margin,
  });

  @override
  _FlipCardWidgetState createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> _curvedAnimation;
  AnimationController _animationController;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    if (widget.listener != null && widget.listener.length >= widget.index)
      widget.listener.add(_flip);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    this._animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listener != null) widget.listener[widget.index] = _flip;

    Widget flipView = FlipView(
      animationController: _curvedAnimation,
      front: _buildCard(context, widget.front),
      back: _buildCard(context, widget.back),
    );
    return widget.isTapFlip
        ? GestureDetector(
            onTap: () => XError.f0(() {
              if (widget.isTapFlip && _flip != null) _flip();
            }),
            child: flipView,
          )
        : flipView;
  }

  Widget _buildCard(BuildContext context, List<Widget> view) {
    double marginHorizontal = 12;
    double marginTop = hp(25);
    double marginBottom = hp(20);
    double width = wp(275);
    double height = hp(504);
    double width27 = wp(105);
    double partPaddingTop = marginTop / 2;

    var margin = widget.margin ??
        EdgeInsets.fromLTRB(
          marginHorizontal,
          marginTop,
          marginHorizontal,
          marginBottom,
        );
    var margin2 = margin.copyWith(
      left: margin.left + margin.top / 2,
      top: margin.top / 2,
    );

    return Stack(
      children: [
        Container(
          height: 30,
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        SizedBox(
          height: double.infinity,
          child: Container(
            margin: margin,
            padding: widget.padding,
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                ),
              ],
            ),
            child: _cardComponents(view, partPaddingTop),
          ),
        ),
        Container(
          height: 30,
          width: width27,
          margin: margin2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            color: Colors.white,
          ),
          child: Center(
            child: AutoSizeText(
              _isFront ? widget.frontText : widget.backText,
              textAlign: TextAlign.justify,
              style: cons.textStyleQuestion,
            ),
          ), // padding: const EdgeInsets.all(0)
        ),
      ],
    );
  }

  void _flip() {
    if (_animationController.isAnimating)
      return;
    else {
      if (_isFront) {
        _animationController.forward();
        _flipAnimation();
      } else {
        _animationController.reverse();
        _flipAnimation();
      }
    }
  }

  void _flipAnimation() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        this._isFront = !this._isFront;
      });

      if (widget.onFlipped != null) {
        widget.onFlipped(_isFront);
      }
    });
  }

  Widget _cardComponents(List<Widget> components, double partPaddingTop) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, partPaddingTop + 5, 0, 0),
      child: ListView.separated(
        itemCount: components.length,
        itemBuilder: (_, int i) {
          return components[i];
        },
        separatorBuilder: (_, __) {
          return SizedBox(height: 10);
        },
      ),
    );
  }
}
