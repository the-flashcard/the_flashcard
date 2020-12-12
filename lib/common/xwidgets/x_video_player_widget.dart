import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/video/video_player_widget.dart';

class XVideoPlayerWidget extends XComponentWidget<core.Video> {
  final Key key;
  Widget child;

  XVideoPlayerWidget(core.Video componentData, int index, {this.key})
      : super(componentData, index, key: key) {
    child = VideoPlayerWidget(
      this.componentData,
      key: this.key,
    );
  }

  @override
  Widget buildComponentWidget(BuildContext context) {
    return child;
  }
}
