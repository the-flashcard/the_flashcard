import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/audio/audio_player_widget.dart';

class XAudioPlayerWidget extends XComponentWidget<core.Audio> {
  final bool showTiming;
  final bool isAutoPlay;

  XAudioPlayerWidget(
    core.Audio componentData,
    int index, {
    Key key,
    XComponentMode mode = XComponentMode.Review,
    this.showTiming,
    this.isAutoPlay,
  }) : super(componentData, index, mode: mode, key: key);

  @override
  Widget buildComponentWidget(BuildContext context) {
    return AudioPlayerWidget(
      this.componentData,
      mode: mode,
      showTiming: showTiming,
      isAutoPlay: isAutoPlay,
    );
  }
}
