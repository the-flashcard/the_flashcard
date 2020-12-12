import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/deck_creation/edit_card_screen.dart';
import 'package:the_flashcard/deck_creation/edit_controller.dart';
import 'package:the_flashcard/deck_creation/image/text_description_widget.dart';
import 'package:the_flashcard/deck_creation/image/x_toolbox_edit_image_widget.dart';

class XEditImageWidget extends StatefulWidget {
  final void Function(core.Image) onEditCompleted;
  final core.Image componentData;
  final VoidCallback onTap;
  final XComponentEditController editController;
  final String nameScreen;

  XEditImageWidget({
    Key key,
    @required this.componentData,
    @required this.onEditCompleted,
    @required this.onTap,
    this.editController,
    this.nameScreen = EditCardScreen.name,
  }) : super(key: key);

  @override
  _XEditImageWidgetState createState() => _XEditImageWidgetState(componentData);
}

class _XEditImageWidgetState extends State<XEditImageWidget>
    with SingleTickerProviderStateMixin
    implements OnImageCreationToolBoxCallback {
  final core.Image _componentData;
  core.ImageConfig config;

  bool _enableEdit = false;
  bool _isRotateOn = false;
  bool _isScaleOn = false;
  bool _isHeightOn = false;
  bool _isShowingImageCreation = false;
  PhotoViewControllerBase photoController = PhotoViewController();
  PhotoViewScaleStateController scaleStateController =
      PhotoViewScaleStateController();

  _XEditImageWidgetState(this._componentData) : assert(_componentData != null) {
    this.config = core.ImageConfig.from(_componentData.imageConfig);
    photoController.updateMultiple(
      position: Offset(config.positionX ?? 0.0, config.positionY ?? 0.0),
      rotationFocusPoint:
          Offset(config.rotationFocusX ?? 0.0, config.rotationFocusY ?? 0.0),
      scale: config.scale ?? 0.1,
      rotation: config.rotate ?? 0.0,
    );

    photoController.outputStateStream.listen((data) {
      core.Log.debug(data);
      config.scale = data.scale ?? core.ImageConfig.DEF_SCALE;
      config.rotate = data.rotation ?? 0.0;
      config.positionX = data.position?.dx ?? 0.0;
      config.positionY = data.position?.dy ?? 0.0;
      config.rotationFocusX = data.rotationFocusPoint?.dx ?? 0.0;
      config.rotationFocusY = data.rotationFocusPoint?.dy ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editController != null)
      widget.editController.addListeners(onEdit: _openToolbox);
    photoController.updateMultiple(
      position:
          Offset(this.config.positionX ?? 0.0, this.config.positionY ?? 0.0),
      rotationFocusPoint: Offset(
          this.config.rotationFocusX ?? 0.0, this.config.rotationFocusY ?? 0.0),
      scale: this.config.scale,
      rotation: this.config.rotate,
    );
    if (widget.editController != null)
      widget.editController.addListeners(onEdit: _openToolbox);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: Container(
          height: wp(config.height ?? core.ImageConfig.DEF_HEIGHT),
          width: wp(255),
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
              color: XedColors.duckEggBlue,
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              border: _enableEdit
                  ? Border.all(color: Colors.pink[300], width: 2.0)
                  : null),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            child: Stack(
              children: <Widget>[
                _componentData.url != null
                    ? PhotoView(
                        backgroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                          color: Colors.transparent,
                        ),
                        loadingBuilder: (_, __) =>
                            Center(child: XedProgress.indicator()),
                        imageProvider: NetworkImage(
                          _componentData.url,
                        ),
                        controller: photoController,
                        scaleStateController: scaleStateController,
                        enableRotation: true,
                        initialScale: config.scale,
                        minScale: core.ImageConfig.MIN_SCALE,
                        maxScale: core.ImageConfig.MAX_SCALE,
                      )
                    : SizedBox(),
                Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.transparent),
                TextDescriptionWidget(
                    canShow: _isRotateOn,
                    title: "Level",
                    description: "${(config.rotate * (180 / pi)).round()}"),
                TextDescriptionWidget(
                    canShow: _isScaleOn,
                    title: "Zoom",
                    description: "x${(config.scale * 10).toStringAsFixed(1)}"),
              ],
            ),
          ),
        ),
        onTap: () => XError.f0(_openToolbox),
      ),
    );
  }

  @override
  void onChanged(core.ImageConfig config) {
    photoController.updateMultiple(
      position: Offset(config.positionX ?? this.config.positionX,
          config.positionY ?? this.config.positionY),
      rotationFocusPoint: Offset(
          this.config.rotationFocusX ?? 0.0, this.config.rotationFocusY ?? 0.0),
      scale: config.scale ?? this.config.scale,
      rotation: config.rotate ?? this.config.rotate,
    );
    this.config.height = config.height;
    setState(() {});
  }

  @override
  void onCancel(core.ImageConfig config) {
    onChanged(config);
    _closeToolbox();
  }

  @override
  void onDone(core.ImageConfig config) {
    onChanged(config);
    _closeToolbox();
    widget.onEditCompleted(core.Image.fromConfig(_componentData, config));
  }

  // void _onDeleteImagePressed() async {
  //   _closeToolbox();
  //   widget.onEditCompleted(null);
  // }

  @override
  void onIconResizePress(bool isOn) {
    setState(() {
      if (isOn) _isRotateOn = false;
      _isScaleOn = isOn;
    });

    core.Log.debug("Resize " + _isScaleOn.toString());
    core.Log.debug("Rotate: " + _isRotateOn.toString());
  }

  @override
  void onIconRotatePress(bool isOn) {
    setState(() {
      if (isOn) _isScaleOn = false;
      _isRotateOn = isOn;
    });
    core.Log.debug("Resize " + _isScaleOn.toString());
    core.Log.debug("Rotate: " + _isRotateOn.toString());
  }

  @override
  void onIconHeightPress(bool isOn) {
    if (isOn) _isHeightOn = false;
    _isHeightOn = isOn;
  }

  void _openToolbox() {
    if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
    core.PopUtils.popUntil(context, widget.nameScreen);
    if (this.widget.onTap != null) this.widget.onTap();
    if (!_enableEdit) {
      setState(() {
        _enableEdit = true;
      });
      _isShowingImageCreation = true;
      Scaffold.of(context)
          .showBottomSheet(
            (context) {
              return XToolboxEditImageWidget(
                callback: this,
                defaultConfig: config,
              );
            },
          )
          .closed
          .whenComplete(() {
            if (mounted) {
              setState(() {
                _enableEdit = false;
              });
            }
          });
    }
  }

  void _closeToolbox() {
    core.PopUtils.popUntil(context, widget.nameScreen);
    setState(() {
      _enableEdit = false;
      if (_isShowingImageCreation) {
        _isScaleOn = false;
        _isRotateOn = false;
        _isShowingImageCreation = false;
      }
    });
  }
}
