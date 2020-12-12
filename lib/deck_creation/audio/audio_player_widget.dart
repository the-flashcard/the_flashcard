import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/audio/x_audio_player.dart';

class AudioPlayerWidget extends StatefulWidget {
  final core.Audio audio;
  final XComponentMode mode;
  final bool showTiming;
  final bool isAutoPlay;

  AudioPlayerWidget(
    this.audio, {
    this.mode = XComponentMode.Review,
    this.showTiming = true,
    this.isAutoPlay,
  });

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends XState<AudioPlayerWidget>
    with WidgetsBindingObserver {
  final AudioPlayerManager audioManager = DI.get(AudioPlayerManager);

  String audioUrl;
  String durationLabel = '00:00:00';
  bool showText = false;
  bool showShadow = false;

  @override
  void initState() {
    super.initState();

    showText = true;
    showShadow = widget.mode == XComponentMode.Editing;

    WidgetsBinding.instance.addObserver(this);
    initAudioPlayer(widget.audio.url);
  }

  void initAudioPlayer(String url) {
    audioUrl = url;
    audioManager.addNew(url);
    audioManager.onAudioPositionChanged(url, (duration) {
      durationLabel = formatDuration(duration);
      reRender();
    });
    audioManager.registerOnAudioStateChanged(url, (state) {
      if (state.index == AudioPlayerState.COMPLETED.index ||
          state.index == AudioPlayerState.STOPPED.index) {
        setState(() {
          durationLabel = "00:00:00";
        });
      } else {
        reRender();
      }
    });
  }

  static String formatDuration(Duration duration) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      duration.inMilliseconds,
      isUtc: true,
    );
    return DateFormat('mm:ss:SS').format(date).substring(0, 8);
  }

  @override
  void dispose() async {
    audioManager.stop(audioUrl);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        audioManager.pause(audioUrl);
        break;

      case AppLifecycleState.detached:
        audioManager.pause(audioUrl);
        break;
      case AppLifecycleState.inactive:
        audioManager.pause(audioUrl);
        break;
      default:
    }
  }

  Future<void> playPlayer() async {
    try {
      if (audioManager.isPlaying(audioUrl)) {
        await audioManager.pause(audioUrl);
      } else {
        await audioManager.play(audioUrl);
      }
      reRender();
    } catch (error) {
      core.Log.error(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: XedColors.white,
              boxShadow: [
                BoxShadow(color: XedColors.blackTwo, blurRadius: 6.0),
              ],
            )
          : BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 12.0),
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 10.0),
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: XedColors.waterMelon,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  color: Colors.white,
                  iconSize: 26,
                  icon: audioManager.isPlaying(widget.audio.url)
                      ? SvgPicture.asset(Assets.icPause, color: XedColors.white)
                      : SvgPicture.asset(Assets.icPlay, color: XedColors.white),
                  onPressed: () async {
                    try {
                      await playPlayer();
                    } catch (ex) {
                      core.Log.error(ex);
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: showText
                    ? Container(
                        padding: const EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        child: Text(
                          widget.audio.textConfig?.isUpperCase == true
                              ? widget.audio.text.toUpperCase()
                              : widget.audio.text,
                          style: widget.audio.textConfig?.toTextStyle(),
                          textAlign: widget.audio.textConfig?.toTextAlign(),
                          maxLines: null,
                        ),
                      )
                    : SizedBox(),
              ),
            ],
          ),
          (widget.showTiming ?? true)
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  alignment: Alignment.centerRight,
                  child: Text(
                    durationLabel,
                    style: RegularTextStyle(12).copyWith(
                      color: XedColors.brownGrey,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
