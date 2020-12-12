import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

abstract class OnImageCreationToolBoxCallback {
  void onIconRotatePress(bool isOn);

  void onIconResizePress(bool isOn);

  void onIconHeightPress(bool isOn);

  void onChanged(core.ImageConfig config);

  void onDone(core.ImageConfig config);

  void onCancel(core.ImageConfig config);
}

class XToolboxEditImageWidget extends StatefulWidget {
  final OnImageCreationToolBoxCallback callback;
  final core.ImageConfig defaultConfig;
  final core.ImageConfig config;

  XToolboxEditImageWidget({
    Key key,
    @required this.defaultConfig,
    this.callback,
  })  : config = core.ImageConfig.from(defaultConfig),
        super(key: key);

  @override
  _XToolboxEditImageWidgetState createState() =>
      _XToolboxEditImageWidgetState();
}

class _XToolboxEditImageWidgetState extends State<XToolboxEditImageWidget> {
  bool _resizing = false;
  bool _rotating = false;
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
                icon: Image.asset(Assets.icRotate,
                    color: _rotating ? Colors.white : Colors.grey),
                onPressed: () => XError.f0(_onRotatePressed),
              ),
              IconButton(
                icon: Image.asset(Assets.icResize,
                    color: _resizing ? Colors.white : Colors.grey),
                onPressed: () => XError.f0(_onResizePressed),
              ),
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
        Column(
          children: <Widget>[
            _rotating
                ? SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        activeTrackColor: XedColors.roseRed,
                        thumbColor: XedColors.roseRed),
                    child: Slider(
                      inactiveColor: XedColors.white,
                      value: widget.config.rotate.clamp(
                          core.ImageConfig.MIN_ROTATE,
                          core.ImageConfig.MAX_ROTATE),
                      min: core.ImageConfig.MIN_ROTATE,
                      max: core.ImageConfig.MAX_ROTATE,
                      onChanged: (newRotate) => XError.f0(
                        () => _onRotateChanged(newRotate),
                      ),
                    ),
                  )
                : SizedBox(),
            _resizing
                ? SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        activeTrackColor: XedColors.roseRed,
                        thumbColor: XedColors.roseRed),
                    child: Slider(
                      inactiveColor: XedColors.white,
                      value: widget.config.scale.clamp(
                          core.ImageConfig.MIN_SCALE,
                          core.ImageConfig.MAX_SCALE),
                      min: core.ImageConfig.MIN_SCALE,
                      max: core.ImageConfig.MAX_SCALE,
                      onChanged: (newScale) => XError.f0(
                        () => _onScaleChanged(newScale),
                      ),
                    ),
                  )
                : SizedBox(),
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
                : SizedBox(),
          ],
        )
      ],
    );
  }

  void _onRotatePressed() {
    if (!_rotating) {
      setState(() {
        _rotating = true;
        _resizing = false;
        _heighting = false;
      });
    } else if (_rotating) {
      setState(() {
        _rotating = false;
      });
    }
    widget?.callback?.onIconRotatePress(_rotating);
  }

  void _onResizePressed() {
    if (!_resizing) {
      setState(() {
        _resizing = true;
        _rotating = false;
        _heighting = false;
      });
    } else if (_resizing) {
      setState(() {
        _resizing = false;
      });
    }
    widget?.callback?.onIconResizePress(_resizing);
  }

  void _onHeightPressed() {
    if (!_heighting) {
      setState(() {
        _heighting = true;
        _resizing = false;
        _rotating = false;
      });
    } else if (_heighting) {
      setState(() {
        _heighting = false;
      });
    }
    widget?.callback?.onIconHeightPress(_heighting);
  }

  void _onScaleChanged(double newScale) {
    setState(() {
      widget.config.scale = newScale ?? core.ImageConfig.DEF_SCALE;
    });
    widget?.callback?.onChanged(widget.config);
  }

  void _onRotateChanged(double newRotate) {
    setState(() {
      widget.config.rotate = newRotate ?? 0.0;
    });

    widget?.callback?.onChanged(widget.config);
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
}
