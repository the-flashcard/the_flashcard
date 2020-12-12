import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_progress.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/video/video.dart';
import 'package:the_flashcard/deck_creation/video/youtube_player_widget.dart';
import 'package:video_player/video_player.dart' as player;

class VideoPlayerWidget extends StatefulWidget {
  final core.Video video;

  VideoPlayerWidget(this.video, {Key key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() {
    return _VideoPlayerWidgetState(video?.url ?? "");
  }
}

class _VideoPlayerWidgetState extends XState<VideoPlayerWidget> {
  static const int LOAD_VIDEO_MAX_RETRY = 2;

  player.VideoPlayerController videoController;
  ChewieController chewieController;

  final String url;
  String youtubeId;
  int numberOfRetry = 0;

  _VideoPlayerWidgetState(this.url) {
    youtubeId = core.VideoUtils.getYoutubeId(url ?? '');
  }

  @override
  void initState() {
    super.initState();
    if (youtubeId == null || youtubeId.isEmpty) {
      _setupVideoPlayer(url);
    }
  }

  @override
  void dispose() {
    videoController?.removeListener(_onVideoStateChanged);
    videoController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  void _setupVideoPlayer(String url) {
    try {
      videoController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoController = player.VideoPlayerController.network(url);
      videoController.addListener(_onVideoStateChanged);
      _initAndLoadVideo();
    } catch (ex) {
      core.Log.error(
          "$runtimeType: _initVideoPlayer: Failed to init player: $ex");
    }
  }

  void _initAndLoadVideo() {
    if (!(videoController.value?.initialized ?? false)) {
      videoController.initialize().whenComplete(() async {
        reRender();
      });
    }
  }

  void _onVideoStateChanged() async {
    try {
      if (videoController.value.hasError ?? false) {
        _retryOnFailure();
      } else {
        final duration = videoController.value?.duration ?? Duration();
        final position = videoController.value?.position ?? Duration();
        if (position >= duration && position.inMilliseconds > 0) {
          await _pauseAndSeekToBeginning();
        }
      }
    } catch (ex, strace) {
      core.Log.error("$runtimeType._onVideoStateChanged: $url - $ex");
      core.Log.debug(strace);
    }
  }

  void _retryOnFailure() {
    core.Log.error(
        "$runtimeType._retryOnFailure: $url - ${videoController.value.errorDescription} retry $numberOfRetry times");
    if (numberOfRetry >= LOAD_VIDEO_MAX_RETRY) {
      reRender();
    } else {
      numberOfRetry++;
      _initAndLoadVideo();
    }
  }

  Future<void> _pauseAndSeekToBeginning() {
    if (videoController != null) {
      return videoController.seekTo(Duration()).whenComplete(() {
        videoController.pause();
      });
    } else {
      return Future.value(() {});
    }
  }

  void _onReloadVideoPressed() {
    numberOfRetry = 0;
    _setupVideoPlayer(url);
    reRender();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (youtubeId == null || youtubeId.isEmpty) {
      child = _buildVideoPlayer(context);
    } else {
      child = YoutubePlayerWidget(youtubeId: youtubeId);
    }
    final double heightVideo =
        this.widget.video?.config?.height ?? core.VideoConfig.DEF_HEIGHT;

    return Container(
      height: hp(heightVideo),
      constraints: BoxConstraints(
        minHeight: hp(core.VideoConfig.MIN_HEIGHT),
        maxHeight: hp(core.VideoConfig.MAX_HEIGHT),
      ),
      child: child,
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(color: XedColors.black),
        Builder(
          builder: (context) {
            final value = videoController.value;
            if (value?.hasError ?? false) {
              return buildError(context, value.errorDescription);
            } else if (value?.initialized ?? false) {
              return Chewie(controller: _buildPlayerController());
            } else
              return Center(child: XedProgress.indicator());
          },
        ),
      ],
    );
  }

  ChewieController _buildPlayerController() {
    if (chewieController == null)
      chewieController = ChewieController(
        aspectRatio: videoController.value.aspectRatio,
        videoPlayerController: videoController,
        customControls: VideoControlWidget(
          iconColor: Colors.white,
          backgroundColor: Color.fromARGB(25, 255, 255, 255),
        ),
        showControls: true,
        autoInitialize: false,
        looping: false,
        placeholder: Center(child: XedProgress.indicator()),
        errorBuilder: buildError,
      );

    return chewieController;
  }

  Widget buildError(BuildContext context, String errorMsg) {
    core.Log.error("$runtimeType.buildError  $errorMsg");
    return GestureDetector(
      onTap: _onReloadVideoPressed,
      child: Center(
        child: Text(
          core.Config.getString("msg_load_video_failed"),
          style: TextStyle(
            color: XedColors.whiteTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
