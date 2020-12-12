import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/resources/assets.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/xwidgets/xwidgets.dart';

class XCardThumbnailWidget extends StatelessWidget {
  final core.Card card;
  final core.Container container;
  final double radius;
  final double sizeIcon;

  XCardThumbnailWidget({
    Key key,
    this.card,
    this.radius = 15,
    this.sizeIcon = 40.0,
  })  : container = card?.getThumbnailCardSide() ?? core.Container(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget = _buildThumbnailWidget();
    return widget is _ImageWidget ? widget : _borderWidget(child: widget);
  }

  Widget _borderWidget({Widget child}) {
    bool isVideoOrAudio = child is _AudioWidget || child is VideoWidget;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(this.radius),
        gradient: isVideoOrAudio ? null : container?.toGradient(),
        color: isVideoOrAudio ? XedColors.duckEggBlue : null,
        boxShadow: <BoxShadow>[
          BoxShadow(color: XedColors.blackTwo, blurRadius: 6, spreadRadius: 0),
        ],
      ),
      child: child,
    );
  }

  Widget _buildThumbnailWidget() {
    core.Component component = _getThumbnailComponent();
    if (component == null)
      return SizedBox();
    else {
      switch (component.runtimeType) {
        case core.Text:
          return _TextWidget(component: component);
          break;
        case core.Image:
          return _ImageWidget(
            component: component,
            borderRadius: this.radius,
          );
        case core.Audio:
          return _AudioWidget(component: component, sizeAudio: sizeIcon);
        case core.Video:
          return VideoWidget(component: component, sizeIcon: sizeIcon);
        default:
          return SizedBox();
      }
    }
  }

  core.Component _getThumbnailComponent() {
    core.Component component;
    try {
      core.Text text;
      core.Text otherText;
      core.Image image;
      core.Image imageAndText;
      core.Audio voice;
      core.Video video;

      container?.components?.forEach((component) {
        switch (component.runtimeType) {
          case core.Text:
            core.Text temp = component as core.Text;
            if (temp.hasText) text ??= component;
            break;
          case core.FillInBlank:
            core.FillInBlank temp = component as core.FillInBlank;
            if (temp.hasQuestion)
              otherText ??= core.Text()..text = temp.question;
            break;
          case core.BaseMC:
            core.BaseMC temp = component as core.BaseMC;
            if (temp.hasQuestion)
              otherText ??= core.Text()..text = temp.question;
            break;
          case core.Image:
            core.Image temp = component as core.Image;
            if (temp.hasUrl) {
              image ??= temp;
              if (temp.text?.isNotEmpty == true) imageAndText ??= temp;
            }
            break;
          case core.Audio:
            core.Audio temp = component as core.Audio;
            if (temp.hasUrl) voice ??= temp;
            break;
          case core.Video:
            core.Video temp = component as core.Video;
            if (temp.hasUrl) video ??= temp;
            break;
          case core.Dictionary:
            core.Dictionary temp = component as core.Dictionary;
            otherText ??= core.Text()..text = temp.word;
            break;
          default:
            if (component is core.BaseMC && component.hasQuestion) {
              otherText ??= core.Text()..text = component.question;
            }
            break;
        }
      });
      component = <core.Component>[
        imageAndText,
        text,
        otherText,
        image,
        voice,
        video
      ].firstWhere((x) => x != null, orElse: () => null);
    } catch (ex) {
      core.Log.error(ex);
    }

    return component;
  }
}

class VideoWidget extends StatelessWidget {
  final core.Video component;
  final double sizeIcon;

  const VideoWidget({Key key, this.component, this.sizeIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String thumbnail =
        core.VideoUtils.getThumbFromVideoUrl(this.component.url);

    return thumbnail is String
        ? XCachedImageWidget(
            url: thumbnail,
            imageBuilder: (BuildContext context, ImageProvider imageProvider) {
              return Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: sizeIcon,
                      width: sizeIcon,
                      decoration: BoxDecoration(
                        color: XedColors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 34,
                        icon: SvgPicture.asset(
                          Assets.icPlay,
                          color: XedColors.white,
                        ),
                        onPressed: null,
                      ),
                    ),
                  ),
                ],
              );
            },
            placeholder: (_, __) {
              return XImageLoading(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: XedColors.white255,
                  ),
                ),
              );
            },
            errorWidget: (context, url, error) => defaultWidget(),
          )
        : defaultWidget();
  }

  Widget defaultWidget() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: XedColors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 0,
            color: XedColors.blackTwo,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: IconButton(
        color: Colors.white,
        iconSize: 34,
        icon: SvgPicture.asset(Assets.icVideoWhite, color: XedColors.black),
        onPressed: null,
      ),
    );
  }
}

class _AudioWidget extends StatelessWidget {
  final core.Audio component;
  final double sizeAudio;

  const _AudioWidget({Key key, this.component, this.sizeAudio})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: XedColors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 0,
            color: XedColors.blackTwo,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: IconButton(
        iconSize: 34,
        icon: SvgPicture.asset(Assets.icVoiceWhite, color: XedColors.black),
        onPressed: null,
      ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  final core.Image component;
  final double borderRadius;

  const _ImageWidget({Key key, this.component, this.borderRadius = 15})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return XCachedImageWidget(
      url: component.url,
      imageBuilder: (BuildContext context, ImageProvider imageProvider) {
        final bool hasText = hasTextComponent();

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(this.borderRadius)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            hasText ? getTextWidget() : SizedBox(),
          ],
        );
      },
      placeholder: (_, __) {
        return XImageLoading(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(this.borderRadius),
              ),
              color: XedColors.white255,
            ),
          ),
        );
      },
    );
  }

  bool hasTextComponent() {
    return component?.text?.isNotEmpty == true ?? false;
  }

  Widget getTextWidget() {
    final textComponent = this.component.getTextComponent();
    return XTextWidget(componentData: textComponent);
  }
}

class _TextWidget extends StatelessWidget {
  final core.Text component;

  const _TextWidget({Key key, this.component}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = component.text;
    core.TextConfig textConfig = core.TextConfig()
      ..isUpperCase = component.textConfig?.isUpperCase ?? false;
    bool isShortText = text.length <= 20;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: wp(10), vertical: hp(10)),
      width: double.infinity,
      child: Text(
        (textConfig?.isUpperCase ?? false) ? text.toUpperCase() : text,
        textAlign: isShortText ? TextAlign.center : TextAlign.left,
        style: textConfig?.toTextStyle(),
      ),
    );
  }
}
