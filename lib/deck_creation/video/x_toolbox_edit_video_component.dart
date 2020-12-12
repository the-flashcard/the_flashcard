import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

abstract class OnVideoEditToolBoxCallback {
  void onIconHeightPress(bool isOn);

  void onChanged(core.VideoConfig config);

  void onDone(core.VideoConfig config);

  void onCancel(core.VideoConfig config);
}

class XToolboxEditVideoComponent extends StatefulWidget {
  final OnVideoEditToolBoxCallback callback;
  final core.VideoConfig defaultConfig;
  final core.VideoConfig config;

  XToolboxEditVideoComponent({
    Key key,
    @required this.defaultConfig,
    this.callback,
  })  : config = core.VideoConfig.from(defaultConfig),
        super(key: key);

  @override
  _XToolboxEditVideoComponentState createState() =>
      _XToolboxEditVideoComponentState();
}

class _XToolboxEditVideoComponentState
    extends State<XToolboxEditVideoComponent> {
  bool _heighting = false;

  @override
  Widget build(BuildContext context) {
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
        SizedBox(height: hp(30)),
        Container(
          width: double.infinity,
          height: hp(44),
          margin: EdgeInsets.symmetric(horizontal: wp(25)),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.14),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  Assets.icResizeHeight,
                  color: _heighting ? Colors.white : Colors.grey,
                ),
                onPressed: () => XError.f0(_onHeightPressed),
              ),
            ],
          ),
        ),
        SizedBox(height: hp(15)),
        _heighting
            ? SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    activeTrackColor: XedColors.roseRed,
                    thumbColor: XedColors.roseRed),
                child: Slider(
                  inactiveColor: XedColors.white,
                  value: widget.config.height,
                  min: core.VideoConfig.MIN_HEIGHT,
                  max: core.VideoConfig.MAX_HEIGHT,
                  onChanged: (newHeight) => XError.f0(
                    () => _onHeightChanged(newHeight),
                  ),
                  // onChangeEnd: (newHeight) => XError.f0(
                  //   () => _onHeightChanged(newHeight),
                  // ),
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
    widget.callback?.onCancel(core.VideoConfig.from(widget.defaultConfig));
  }

  void _onDonePressed() {
    widget.callback?.onDone(widget.config);
  }
}
