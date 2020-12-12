import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/gradient_color.dart';
import 'package:the_flashcard/xerror.dart';

abstract class XColorToolBoxCallBack {
  void onColorChange(LinearGradient value); //selected position
  void applyChanged();

  void cancelChanged(LinearGradient oldValue);

  void backPressed();
}

class XGradientColorToolBoxWidget extends StatefulWidget {
  final String configTitle;
  final XColorToolBoxCallBack callBack; //selected position
  final Gradient gradientDefault;

  XGradientColorToolBoxWidget({
    @required this.configTitle,
    @required this.callBack,
    @required this.gradientDefault,
  });

  @override
  _XGradientColorToolBoxWidgetState createState() =>
      _XGradientColorToolBoxWidgetState();
}

class _XGradientColorToolBoxWidgetState
    extends State<XGradientColorToolBoxWidget> {
  int index = 0;
  final scrollController = ScrollController();
  final physis = BouncingScrollPhysics();
  final _itemExtend = 50.0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < gradients.length; ++i) {
      if (_compareGradient(
        gradients[i],
        this.widget.gradientDefault,
      )) {
        index = i;
        break;
      }
    }
    Future.delayed(const Duration(milliseconds: 150)).whenComplete(() {
      moveToIndex(index);
    });
  }

  bool _compareGradient(Gradient a, Gradient b) {
    if (a == null || b == null || a.colors.length != b.colors.length)
      return false;

    for (int i = 0; i < a.colors.length; ++i) {
      if (a.colors[i].value != b.colors[i].value) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      height: 137,
      color: XedColors.black,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _buildToolboxItemList()),
            Container(
              width: double.infinity,
              height: hp(1),
              color: Color.fromRGBO(255, 255, 255, 0.16),
            ),
            _addEditRow()
          ],
        ),
      ),
    );
  }

  Widget _addEditRow() {
    return Container(
      width: double.infinity,
      height: 47,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.keyboard_backspace,
                  size: hp(20),
                  color: XedColors.white,
                ),
                onPressed: () => XError.f0(() {
                  widget.callBack?.backPressed();
                }),
              ),
              Center(
                child: Text(
                  widget.configTitle,
                  textAlign: TextAlign.center,
                  style: ColorTextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: wp(40))
            ],
          ),
          Container(
            // margin: EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => XError.f0(() {
                widget.callBack?.applyChanged();
              }),
              iconSize: hp(20),
              icon: Icon(Icons.close),
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  ListView _buildToolboxItemList() {
    return ListView.builder(
      itemCount: gradients.length,
      physics: physis,
      controller: this.scrollController,
      itemExtent: this._itemExtend,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) =>
          _buildToolboxItem(gradients[index], index),
    );
  }

  Widget _buildToolboxItem(Gradient gradient, int i) {
    return InkWell(
      splashColor: XedColors.black,
      highlightColor: XedColors.black,
      onTap: () => XError.f0(() {
        moveToIndex(i);
        setState(() {
          index = i;
        });
        widget.callBack?.onColorChange(gradient);
      }),
      child: Container(
        width: hp(53),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              index == i
                  ? Container(
                      width: hp(29),
                      height: hp(29),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: XedColors.white,
                          width: hp(1),
                        ),
                      ),
                    )
                  : SizedBox(),
              Container(
                width: hp(25),
                height: hp(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: XedColors.white,
                    width: hp(1),
                  ),
                  // color: color,
                  gradient: gradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToIndex(int index) {
    if (isScroll(index)) {
      final double offset = getOffset(index);
      this.scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
    }
  }

  bool isScroll(int index) {
    try {
      if (this.scrollController.offset > 0 &&
          this.scrollController.offset <
              this.scrollController.position.maxScrollExtent) return true;
      return index > 4 && index < gradients.length - 4;
    } catch (ex) {
      return false;
    }
  }

  double getOffset(int index) {
    try {
      final offset = (index - 4) * _itemExtend;
      if (offset < 0) return 0.0;
      if (offset > this.scrollController.position.maxScrollExtent)
        return this.scrollController.position.maxScrollExtent;
      return offset;
    } catch (ex) {
      return 0.0;
    }
  }
}
