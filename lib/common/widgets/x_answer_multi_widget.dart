import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/audio/x_audio_player.dart';

class XAnswerMultiWidget extends StatelessWidget {
  final core.Answer component;
  final bool isSelected;
  final bool isUserChoice;
  final XComponentMode mode;

  const XAnswerMultiWidget({
    Key key,
    this.component,
    this.isSelected = false,
    this.isUserChoice = false,
    this.mode = XComponentMode.Review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return component.hasUrl() ? _buildMultiWidget() : _buildOnlyText();
  }

  Widget _buildImageAndAudio() {
    return Stack(
      children: <Widget>[
        _buildImage(),
        _buildAudio(),
      ],
    );
  }

  Widget _buildText(bool fill) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: fill
            ? BorderRadius.circular(16)
            : BorderRadius.only(
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
      ),
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          component.text,
          style: component.textConfig?.toTextStyle(),
          textAlign: component.textConfig?.toTextAlign(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    BorderRadius borderRadius = component.text?.isNotEmpty == true
        ? BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          )
        : BorderRadius.circular(13);
    double height = hp(120);
    return Stack(
      children: <Widget>[
        isEmpty(component.imageUrl)
            ? _defaultImage(height, borderRadius)
            : _getImage(component.imageUrl, height, borderRadius),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(0, 0, 0, 0),
                Color.fromARGB(25, 0, 0, 0),
                Color.fromARGB(75, 0, 0, 0),
              ],
              stops: [0.5, 0.68, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _getImage(
    String url,
    double height,
    BorderRadius borderRadius,
  ) {
    return XCachedImageWidget(
      url: url,
      height: height,
      imageBuilder: (_, ImageProvider imageProvider) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Color.fromARGB(255, 220, 221, 221),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: imageProvider,
            ),
          ),
        );
      },
      placeholder: (_, __) {
        return XImageLoading(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.white,
            ),
          ),
        );
      },
      errorWidget: (_, __, ___) {
        return _defaultImage(height, borderRadius);
      },
    );
  }

  static Widget _defaultImage(
    double height,
    BorderRadius borderRadius,
  ) {
    final String image = "assets/images/componentImgGray.png";
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: XedColors.paleGrey,
        image: DecorationImage(
          image: AssetImage(image),
        ),
      ),
    );
  }

  bool isEmpty(String url) {
    return url == null || url.trim().isEmpty;
  }

  Widget _buildAudio() {
    double size = hp(30);
    double sizeIcon = hp(20);
    double top = hp(83.8);
    double left = wp(10);
    return isEmpty(component.audioUrl)
        ? SizedBox()
        : Container(
            height: size,
            width: size,
            margin: EdgeInsets.only(left: left, top: top),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              heroTag: this.hashCode,
              onPressed: () => XError.f0(() {
                AudioPlayerManager.player.play(component.audioUrl);
              }),
              child: Icon(
                Icons.volume_up,
                size: sizeIcon,
                color: XedColors.waterMelon,
              ),
            ),
          );
  }

  Widget _buildMultiWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? XedColors.waterMelon : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? XedColors.carnationColor : XedColors.blackTwo,
            blurRadius: 6,
          )
        ],
      ),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          _buildImageAndAudio(),
          this.component.text?.isNotEmpty == true
              ? _buildText(false)
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildOnlyText() {
    double height = hp(120);

    return Container(
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? XedColors.waterMelon : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? XedColors.carnationColor : XedColors.blackTwo,
            blurRadius: 6,
          )
        ],
      ),
      child: _buildText(true),
    );
  }
}
