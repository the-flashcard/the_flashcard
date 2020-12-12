import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/xerror.dart';

abstract class XAlignmentToolBoxCallBack {
  void alignmentChanged(core.XCardAlignment value); //selected position
  void applyAlignmentChanged();

  void cancelAlignmentChanged(core.XCardAlignment oldValue);

  void backAlignmentPressed();
}

class AlignmentModel {
  final core.XCardAlignment alignment;
  final SvgPicture asset;

  AlignmentModel(this.alignment, this.asset);
}

class XAlignmentToolBoxWidget extends StatefulWidget {
  final String configTitle;
  final XAlignmentToolBoxCallBack callBack; //selected position
  final core.XCardAlignment alignmentDefault;

  XAlignmentToolBoxWidget({
    @required this.configTitle,
    @required this.callBack,
    @required this.alignmentDefault,
  });

  @override
  _XAlignmentToolBoxWidgetState createState() =>
      _XAlignmentToolBoxWidgetState();
}

class _XAlignmentToolBoxWidgetState extends State<XAlignmentToolBoxWidget> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.alignmentDefault.index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: double.infinity,
      height: hp(159),
      color: XedColors.black,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Expanded(child: _buildAlignment()),
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
      height: hp(46),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.keyboard_backspace,
                  size: hp(20),
                  color: XedColors.white,
                ),
                onPressed: () => XError.f0(() {
                  widget.callBack?.backAlignmentPressed();
                }),
              ),
              Text(
                widget.configTitle,
                textAlign: TextAlign.center,
                style: ColorTextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: wp(30))
            ],
          ),
          Container(
            margin: EdgeInsets.only(right: wp(30)),
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => XError.f0(() {
                widget.callBack?.applyAlignmentChanged();
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

  Widget _buildAlignment() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: wp(25), vertical: hp(30)),
      padding: EdgeInsets.symmetric(horizontal: wp(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(hp(10))),
        color: XedColors.divider,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                index = core.XCardAlignment.Top.index;
              });
              widget.callBack?.alignmentChanged(core.XCardAlignment.Top);
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                child: SvgPicture.asset(
                  Assets.icTop,
                  color: index == core.XCardAlignment.Top.index
                      ? XedColors.white
                      : null,
                ),
                width: hp(24),
                height: hp(24),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                index = core.XCardAlignment.Center.index;
                widget.callBack?.alignmentChanged(core.XCardAlignment.Center);
              });
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                child: SvgPicture.asset(
                  Assets.icCenter,
                  color: index == core.XCardAlignment.Center.index
                      ? XedColors.white
                      : null,
                ),
                width: hp(24),
                height: hp(24),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                index = core.XCardAlignment.Bottom.index;
                widget.callBack?.alignmentChanged(core.XCardAlignment.Bottom);
              });
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                child: SvgPicture.asset(
                  Assets.icBottom,
                  color: index == core.XCardAlignment.Bottom.index
                      ? XedColors.white
                      : null,
                ),
                width: hp(24),
                height: hp(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
