import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_iconic_flutter/open_iconic_flutter.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/video/video.dart';
import 'package:video_player/video_player.dart';

class VideoControlWidget extends StatefulWidget {
  const VideoControlWidget({
    @required this.backgroundColor,
    @required this.iconColor,
  });

  final Color backgroundColor;
  final Color iconColor;

  @override
  State<StatefulWidget> createState() {
    return _VideoControlWidgetState();
  }
}

class _VideoControlWidgetState extends State<VideoControlWidget> {
  final marginSize = 5.0;
  final _time = 10;
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;

  Timer _expandCollapseTimer;
  Timer _initTimer;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    chewieController = ChewieController.of(context);

    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(
              context,
              chewieController.videoPlayerController.value.errorDescription,
            )
          : Center(
              child: Icon(
                OpenIconicIcons.ban,
                color: Colors.white,
                size: 42,
              ),
            );
    }

    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;
    final backgroundColor = widget.backgroundColor;
    final iconColor = widget.iconColor;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 24.0 : 47.0;
    final buttonPadding = orientation == Orientation.portrait ? 16.0 : 24.0;

    return GestureDetector(
      onTap: () => XError.f0(() {
        _cancelAndRestartTimer();
      }),
      child: AbsorbPointer(
        absorbing: _hideStuff,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildTopBar(backgroundColor, iconColor, barHeight, buttonPadding),
            _buildHitArea(),
            _buildMiddleBar(backgroundColor, iconColor, barHeight * 2),
            _buildHitArea(),
            _buildBottomBar(backgroundColor, iconColor, barHeight),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_onVideoLoadingState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  AnimatedOpacity _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.all(marginSize),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: chewieController.isLive
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _buildLive(iconColor),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        _buildPosition(iconColor),
                        _buildProgressBar(),
                        _buildRemaining(iconColor)
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedOpacity _buildMiddleBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: chewieController.isLive
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildPlayPause(controller, iconColor, barHeight),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildSkipBack(iconColor, barHeight),
                _buildPlayPause(controller, iconColor, barHeight),
                _buildSkipForward(iconColor, barHeight),
              ],
            ),
    );
  }

  Widget _buildLive(Color iconColor) {
    return Padding(
      padding: EdgeInsets.only(right: 12.0),
      child: Text(
        'LIVE',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildExpandButton(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: () => XError.f0(_onExpandCollapse),
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0),
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: buttonPadding,
                right: buttonPadding,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Center(
                child: Icon(
                  chewieController.isFullScreen
                      ? OpenIconicIcons.fullscreenExit
                      : OpenIconicIcons.fullscreenEnter,
                  color: iconColor,
                  size: 12.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: () => XError.f0(
          _latestValue != null && _latestValue.isPlaying
              ? _cancelAndRestartTimer
              : () {
                  _hideTimer?.cancel();

                  setState(() {
                    _hideStuff = false;
                  });
                },
        ),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return GestureDetector(
      onTap: () => XError.f0(
        () {
          _cancelAndRestartTimer();

          if (_latestValue.volume == 0) {
            controller.setVolume(_latestVolume ?? 0.5);
          } else {
            _latestVolume = controller.value.volume;
            controller.setVolume(0.0);
          }
        },
      ),
      child: AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Container(
                height: barHeight,
                padding:
                    EdgeInsets.only(left: buttonPadding, right: buttonPadding),
                child: Icon(
                  (_latestValue != null && _latestValue.volume > 0)
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: iconColor,
                  size: 16.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    if (controller.value != null &&
        (controller.value.position ?? Duration()) >=
            (controller.value.duration ?? Duration())) {
      controller.seekTo(Duration(seconds: 0));
      controller.pause();
    }
    return GestureDetector(
      onTap: () => XError.f0(_playPause),
      child: Container(
        alignment: Alignment.center,
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(left: 6.0, right: 6.0),
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: iconColor,
          size: 48.0,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position =
        _latestValue != null ? _latestValue.position : Duration(seconds: 0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue != null && _latestValue.duration != null
        ? _latestValue.duration - _latestValue.position
        : Duration(seconds: 0);

    return Padding(
      padding: EdgeInsets.only(right: 12.0),
      child: Text(
        '${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () => XError.f0(_skipBack),
      child: Container(
        alignment: Alignment.center,
        height: barHeight,
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 10.0),
        padding: EdgeInsets.only(left: 6.0, right: 6.0),
        child: Icon(Icons.fast_rewind, color: iconColor, size: 30.0),
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () => XError.f0(_skipForward),
      child: Container(
        alignment: Alignment.center,
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(left: 6.0, right: 8.0),
        margin: EdgeInsets.only(right: 8.0),
        child: Icon(Icons.fast_forward, color: iconColor, size: 30.0),
      ),
    );
  }

  Widget _buildTopBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double buttonPadding,
  ) {
    return Container(
      height: barHeight,
      margin: EdgeInsets.only(
        top: marginSize,
        right: marginSize,
        left: marginSize,
      ),
      child: Row(
        children: <Widget>[
          chewieController.allowFullScreen
              ? _buildExpandButton(
                  backgroundColor,
                  iconColor,
                  barHeight,
                  buttonPadding,
                )
              : Container(),
          Expanded(child: Container()),
          chewieController.allowMuting
              ? _buildMuteButton(
                  controller,
                  backgroundColor,
                  iconColor,
                  barHeight,
                  buttonPadding,
                )
              : Container(),
        ],
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();

    setState(() {
      _hideStuff = false;

      _startHideTimer();
    });
  }

  Future<void> _initialize() async {
    controller.addListener(_onVideoLoadingState);
    _onVideoLoadingState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    _initTimer = Timer(Duration(milliseconds: 200), () {
      setState(() {
        _hideStuff = false;
      });
    });
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;

      chewieController.toggleFullScreen();
      _expandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: CupertinoVideoProgressBar(
          controller,
          onDragStart: () {
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            _startHideTimer();
          },
          colors: chewieController.cupertinoProgressColors ??
              ChewieProgressColors(
                playedColor: Color.fromARGB(120, 255, 255, 255),
                handleColor: Color.fromARGB(255, 255, 255, 255),
                bufferedColor: Color.fromARGB(60, 255, 255, 255),
                backgroundColor: Color.fromARGB(20, 255, 255, 255),
              ),
        ),
      ),
    );
  }

  void _playPause() {
    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          controller.play();
        }
        _cancelAndRestartTimer();
      }
    });
  }

  void _skipBack() {
    bool isPlay = controller.value.isPlaying;
    _cancelAndRestartTimer();
    final beginning = Duration(seconds: 0).inMilliseconds;
    final skip =
        (_latestValue.position - Duration(seconds: _time)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.max(skip, beginning)));

    if (!isPlay) controller.pause();
  }

  void _skipForward() {
    final end = _latestValue.duration.inMilliseconds;
    final skip =
        (_latestValue.position + Duration(seconds: _time)).inMilliseconds;
    controller.seekTo(Duration(milliseconds: math.min(skip, end)));
    _cancelAndRestartTimer();
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _onVideoLoadingState() {
    setState(() {
      _latestValue = controller.value;
    });
  }
}
