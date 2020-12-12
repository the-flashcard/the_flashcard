import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/xwidgets/x_component_widget.dart';

class XImageWidget extends XComponentWidget<core.Image> {
  final PhotoViewControllerBase controller = PhotoViewController();
  static final random = Random();

  XImageWidget({
    @required core.Image componentData,
    @required int index,
    XComponentMode mode,
  }) : super(
          componentData,
          index,
          mode: mode,
        ) {
    controller.updateMultiple(
        position: Offset(componentData.imageConfig?.positionX ?? 0.0,
            componentData.imageConfig?.positionY ?? 0.0),
        rotationFocusPoint: Offset(
            componentData.imageConfig.rotationFocusX ?? 0.0,
            componentData.imageConfig.rotationFocusY ?? 0.0),
        scale: componentData.imageConfig?.scale ?? core.ImageConfig.DEF_SCALE,
        rotation: componentData.imageConfig?.rotate ?? 0.0);
  }

  @override
  Widget buildComponentWidget(BuildContext context) {
    // Dimens.context = context;
    controller.updateMultiple(
        position: Offset(componentData.imageConfig?.positionX ?? 0.0,
            componentData.imageConfig?.positionY ?? 0.0),
        rotationFocusPoint: Offset(
            componentData.imageConfig.rotationFocusX ?? 0.0,
            componentData.imageConfig.rotationFocusY ?? 0.0),
        scale: componentData.imageConfig?.scale ?? core.ImageConfig.DEF_SCALE,
        rotation: componentData.imageConfig?.rotate ?? 0.0);

    return Container(
      height: wp(componentData.imageConfig.height),
      width: wp(255),
      margin: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: XedColors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(hp(15.0)),
        ),
      ),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(hp(15.0))),
            child: componentData.url != null
                ? XCachedImageWidget(
                    url: componentData.url,
                    height: hp(
                      componentData.imageConfig.height ??
                          core.ImageConfig.DEF_HEIGHT,
                    ),
                    placeholder: (_, __) {
                      return Center(child: XedProgress.indicator());
                    },
                    imageBuilder: (_, ImageProvider imageProvider) {
                      return PhotoView(
                        heroAttributes: PhotoViewHeroAttributes(
                            tag: random.nextInt(100000)),
                        backgroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(hp(15.0)),
                          ),
                          color: Colors.transparent,
                        ),
                        imageProvider: imageProvider,
                        controller: controller,
                        enableRotation: true,
                        initialScale: componentData.imageConfig?.scale ??
                            core.ImageConfig.DEF_SCALE,
                        minScale: core.ImageConfig.MIN_SCALE,
                        maxScale: core.ImageConfig.MAX_SCALE,
                      );
                    },
                  )
                : SizedBox(),
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            color: XedColors.transparent,
          ),
        ],
      ),
    );
  }
}
