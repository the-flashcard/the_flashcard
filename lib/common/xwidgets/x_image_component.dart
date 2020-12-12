import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/xwidgets/x_component_widget.dart';

class XImageComponent extends XComponentWidget<core.Image> {
  XImageComponent({
    @required core.Image componentData,
    @required int index,
    XComponentMode mode,
  }) : super(componentData, index, mode: mode);

  @override
  Widget buildComponentWidget(BuildContext context) {
    return Container(
      height: wp(componentData.imageConfig.height),
      width: wp(255),
      margin: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: XedColors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(hp(15.0))),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(hp(15.0))),
        child: componentData?.url != null ? _buildImage() : SizedBox(),
      ),
    );
  }

  Widget _buildImage() {
    final bool hasTextComponent = this.componentData?.text != null ?? false;
    core.Text textComponent;
    if (hasTextComponent)
      textComponent = this.componentData?.getTextComponent();
    return XCachedImageWidget(
      url: componentData.url,
      height: hp(
        componentData?.imageConfig?.height ?? core.ImageConfig.DEF_HEIGHT,
      ),
      placeholder: (_, __) {
        return Center(child: XedProgress.indicator());
      },
      imageBuilder: (_, ImageProvider imageProvider) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: hp(
                componentData?.imageConfig?.height ??
                    core.ImageConfig.DEF_HEIGHT,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            textComponent != null
                ? XTextWidget(componentData: textComponent)
                : SizedBox()
          ],
        );
      },
    );
  }
}
