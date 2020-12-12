import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

abstract class OnImageEditToolBoxCallback {
  void onIconHeightPress(bool isOn);

  void onChanged(core.ImageConfig config);

  void onDone(core.ImageConfig config);

  void onCancel(core.ImageConfig config);

  void onAddTextPressed();

  void onRemoveTextPressed();
}

enum XToolboxEditImageMode {
  AddText,
  RemoveText,
}

class XToolboxEditImageComponent extends StatefulWidget {
  final OnImageEditToolBoxCallback callback;
  final core.ImageConfig defaultConfig;
  final core.ImageConfig config;
  final XToolboxEditImageMode mode;

  XToolboxEditImageComponent({
    Key key,
    @required this.defaultConfig,
    @required this.mode,
    this.callback,
  })  : config = core.ImageConfig.from(defaultConfig),
        super(key: key);

  @override
  _XToolboxEditImageComponentState createState() =>
      _XToolboxEditImageComponentState();
}

class _XToolboxEditImageComponentState
    extends State<XToolboxEditImageComponent> {
  bool _heighting = false;

  @override
  Widget build(BuildContext context) {
    // Dimens.context = context;
    return Container(
      height: hp(200),
      color: XedColors.black,
      child: Column(
        children: <Widget>[
          _buildActionBarView(),
          _editPanelWidget(),
        ],
      ),
    );
  }

  /// Action menu items
  Widget _buildActionBarView() {
    return Row(
      children: <Widget>[
        FlatButton(
          child: Text(
            "Cancel",
            style: RegularTextStyle(15)
                .copyWith(letterSpacing: 0.5, color: XedColors.whiteTextColor),
          ),
          onPressed: () => XError.f0(_onCancelPressed),
        ),
        widget.mode == XToolboxEditImageMode.AddText
            ? FlatButton(
                child: Text(
                  "Add text",
                  style: RegularTextStyle(15).copyWith(
                      letterSpacing: 0.5, color: XedColors.whiteTextColor),
                ),
                onPressed: () => XError.f0(_onAddText),
              )
            : SizedBox(),
        widget.mode == XToolboxEditImageMode.RemoveText
            ? FlatButton(
                child: Text(
                  "Remove text",
                  style: RegularTextStyle(15).copyWith(
                      letterSpacing: 0.5, color: XedColors.whiteTextColor),
                ),
                onPressed: () => XError.f0(_onRemoveText),
              )
            : SizedBox(),
        Spacer(),
        IconButton(
          color: XedColors.whiteTextColor,
          icon: Icon(Icons.check),
          onPressed: () => XError.f0(_onDonePressed),
        )
      ],
    );
  }

  /// Action Edit Panel
  Widget _editPanelWidget() {
    return Column(
      children: <Widget>[
        Container(
          height: 1,
          color: Color.fromARGB(41, 255, 255, 255),
        ),
        SizedBox(
          height: hp(30),
        ),
        Container(
          width: double.infinity,
          height: hp(44),
          margin: EdgeInsets.symmetric(horizontal: wp(25)),
          decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.14),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(Assets.icResizeHeight,
                    color: _heighting ? Colors.white : Colors.grey),
                onPressed: () => XError.f0(_onHeightPressed),
              ),
            ],
          ),
        ),
        SizedBox(
          height: hp(15),
        ),
        _heighting
            ? SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    activeTrackColor: XedColors.roseRed,
                    thumbColor: XedColors.roseRed),
                child: Slider(
                  inactiveColor: XedColors.white,
                  value: widget.config.height,
                  min: core.ImageConfig.MIN_HEIGHT,
                  max: core.ImageConfig.MAX_HEIGHT,
                  onChanged: (newHeight) => XError.f0(
                    () => _onHeightChanged(newHeight),
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }

  void _onHeightPressed() {
    if (!_heighting) {
      _heighting = true;
    } else {
      _heighting = false;
    }
    setState(() {});
    widget?.callback?.onIconHeightPress(_heighting);
  }

  void _onHeightChanged(double newHeight) {
    setState(() {
      widget.config.height = newHeight ?? core.ImageConfig.DEF_HEIGHT;
    });
    widget?.callback?.onChanged(widget.config);
  }

  void _onCancelPressed() {
    widget?.callback?.onCancel(core.ImageConfig.from(widget.defaultConfig));
  }

  void _onDonePressed() {
    widget?.callback?.onDone(widget.config);
  }

  void _onRemoveText() {
    widget.callback?.onRemoveTextPressed();
  }

  void _onAddText() {
    widget.callback?.onAddTextPressed();
  }
}
