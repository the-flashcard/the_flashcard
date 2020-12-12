import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/resources/xed_text_styles.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';

enum AudioType {
  Local,
  Record,
  Url,
}

class AudioEditingScreen extends StatefulWidget {
  static const name = '/AudioEditingScreen';
  final String audioName;
  final String url;

  final bool showInputTextField;
  final bool showIconRemove;
  final core.Audio model;
  final AudioType audioType;

  const AudioEditingScreen.local({
    Key key,
    @required this.audioName,
    this.showInputTextField = true,
    this.showIconRemove = true,
  })  : model = null,
        url = null,
        audioType = AudioType.Local,
        super(key: key);

  const AudioEditingScreen.record({
    Key key,
    @required this.audioName,
    this.showInputTextField = true,
    this.showIconRemove = true,
  })  : model = null,
        url = null,
        audioType = AudioType.Record,
        super(key: key);

  AudioEditingScreen.inputUrl({
    Key key,
    @required this.url,
    this.showInputTextField = true,
    this.showIconRemove = true,
    String text,
  })  : model = core.Audio(text: text),
        audioName = null,
        audioType = AudioType.Url,
        super(key: key);

  const AudioEditingScreen.edit(
      {Key key,
      this.model,
      this.showInputTextField = true,
      this.showIconRemove = true,
      @required this.audioType})
      : audioName = null,
        url = null,
        super(key: key);

  @override
  _AudioEditingScreenState createState() => _AudioEditingScreenState();
}

class _AudioEditingScreenState extends XState<AudioEditingScreen>
    with OnTextToolBoxCallBack {
  final node = FocusNode();
  final textEditingController = TextEditingController();
  final FlutterSound audioPlayer = FlutterSound();
  final listener = ValueNotifier<void>(() {});
  Key key = UniqueKey();
  double audioPosition = 0.0;
  double audioDuration = 1.0;
  bool isEditing = false;
  bool isPlaying = false;
  String audioResult;
  StreamSubscription playerSubscription;
  String playerText = '00:00:00';
  Directory directory;
  File file;
  core.TextConfig textConfig;

  @override
  void initState() {
    super.initState();
    textConfig = _getTextConfig();
    widget.model ?? loadAudio();
    textEditingController.text = widget.model?.text ?? '';
  }

  @override
  void dispose() {
    if (audioPlayer.isPlaying) {
      audioPlayer?.stopPlayer();
    }
    super.dispose();
  }

  core.TextConfig _getTextConfig() {
    return widget.model != null
        ? core.TextConfig.fromJson(widget.model.textConfig.toJson())
        : core.TextConfig()
      ..textAlign = TextAlign.left.index;
  }

  void loadAudio() async {
    switch (widget.audioType) {
      case AudioType.Record:
        directory = await getTemporaryDirectory();
        file = File('${directory.path}/${widget.audioName}');
        break;
      case AudioType.Local:
        file = File(widget.audioName);
        break;
      default:
    }
  }

  String getAudioPath() {
    switch (widget.audioType) {
      case AudioType.Local:
        return widget.audioName;
        break;
      case AudioType.Record:
        return '${directory.path}/${widget.audioName}';
        break;
      default:
        return this.widget.url ?? this.widget.model?.url;
    }
  }

  Future<void> playPlayer(BuildContext context) async {
    if (audioPosition == 0) {
      String link = getAudioPath();
      if (link != null) {
        try {
          audioResult = await audioPlayer.startPlayer(link);
          core.Log.debug('startPlayer $audioResult');
          try {
            playerSubscription =
                audioPlayer.onPlayerStateChanged.listen((data) {
              if (data != null) {
                audioDuration = data.duration;
                DateTime date = DateTime.fromMillisecondsSinceEpoch(
                  data.currentPosition.toInt(),
                  isUtc: true,
                );
                setState(() {
                  audioPosition = data.currentPosition;
                  playerText =
                      DateFormat('mm:ss:SS').format(date).substring(0, 8);
                });
                if (audioPosition == audioDuration) {
                  core.Log.debug('end and reset');
                  audioPosition = 0.0;
                  isPlaying = false;
                }
              }
            });
            isPlaying = true;
          } catch (error) {
            core.Log.error(error);
            showErrorSnakeBar(
              'Can\'t player audio, please try again!',
              context: context,
            );
          }
        } catch (error) {
          core.Log.error(error);
          showErrorSnakeBar(
            'Can\'t player audio, please try again!',
            context: context,
          );
        }
      } else {
        showErrorSnakeBar(
          'Can\'t player audio, please try again!',
          context: context,
        );
      }
    } else {
      await audioPlayer.resumePlayer();
      isPlaying = true;
    }
  }

  Future<void> pausePlayer() async {
    try {
      audioResult = await audioPlayer.pausePlayer();
      isPlaying = false;
    } catch (error) {
      core.Log.debug(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    double w10 = wp(10);
    double w15 = wp(15);
    double w30 = wp(30);
    double h5 = hp(5);
    // double h40 = hp(40);
    return Scaffold(
      body: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: hp(43),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: wp(15)),
                          IconButton(
                            icon: Icon(Icons.close),
                            iconSize: hp(30),
                            onPressed: () => XError.f0(
                              () => Navigator.of(context).pop(),
                            ),
                          ),
                          Spacer(),
                          Text('Your Voice', style: BoldTextStyle(18)),
                          Spacer(),
                          SizedBox(width: wp(60)),
                        ],
                      ),
                    ),
                    Divider(height: hp(1)),
                  ],
                ),
              ),
              SizedBox(height: hp(30)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: w15),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${DateFormat.yMMMd().format(DateTime.now())}',
                  style: SemiBoldTextStyle(18),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: w15, vertical: h5),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${DateFormat.Hm().format(DateTime.now())}',
                      style: RegularTextStyle(14)
                          .copyWith(color: XedColors.battleShipGrey),
                    ),
                    Text(
                      playerText,
                      style: RegularTextStyle(14)
                          .copyWith(color: XedColors.battleShipGrey),
                    ),
                  ],
                ),
              ),
              Slider(
                activeColor: XedColors.brownGrey,
                value: audioPosition,
                min: 0.0,
                max: audioDuration,
                onChanged: (double value) {
                  XError.f0(() async =>
                      await audioPlayer.seekToPlayer(value.toInt()));
                },
                divisions: audioDuration.toInt(),
              ),
              widget.showInputTextField
                  ? Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: w15),
                        padding: EdgeInsets.symmetric(
                            horizontal: w15, vertical: w10),
                        // alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 10),
                              blurRadius: 20,
                              color: XedColors.blackTwo,
                            ),
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: TextField(
                          key: key,
                          maxLines: null,
                          controller: textEditingController,
                          onTap: () => XError.f0(() {
                            listener.value = () {};
                            setState(() {
                              isEditing = true;
                            });
                          }),
                          focusNode: node,
                          style: textConfig.toTextStyle(),
                          textAlign: textConfig.toTextAlign(),
                          cursorColor: XedColors.waterMelon,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                core.Config.getString("msg_fill_sub_content"),
                            hintStyle: ColorTextStyle(
                              fontSize: 14.0,
                              color: XedColors.battleShipGrey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          isEditing
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: XToolboxEditTextWidget(
                    defaultConfig: this.textConfig,
                    callback: this,
                    focusNode: node,
                    listenerHideEditPanel: listener,
                  ),
                )
              : SizedBox(),
        ],
      ),
      bottomNavigationBar: isEditing
          ? SizedBox()
          : BottomAppBar(
              color: XedColors.black,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: w15),
                height: hp(56),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildRemoveOrCancelButton(),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.fast_rewind,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            try {
                              int skipPosition = (audioPosition - 5000).toInt();
                              core.Log.debug(audioPosition);
                              core.Log.debug(skipPosition);
                              await audioPlayer.seekToPlayer(skipPosition);
                            } catch (ex) {
                              core.Log.error(ex);
                            }
                          },
                        ),
                        SizedBox(width: w30),
                        Builder(
                          builder: (context) => IconButton(
                            icon: isPlaying
                                ? SvgPicture.asset(Assets.icPause,
                                    color: XedColors.white)
                                : SvgPicture.asset(Assets.icPlay,
                                    color: XedColors.white),
                            iconSize: 30,
                            color: Colors.white,
                            onPressed: () async {
                              try {
                                isPlaying
                                    ? await pausePlayer()
                                    : await playPlayer(context);
                              } catch (ex) {
                                core.Log.error(ex);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: w30),
                        IconButton(
                          icon: Icon(
                            Icons.fast_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            try {
                              int skipPosition = (audioPosition + 5000).toInt();
                              core.Log.debug(audioPosition);
                              core.Log.debug(skipPosition);
                              await audioPlayer.seekToPlayer(skipPosition);
                            } catch (ex) {
                              core.Log.error(ex);
                            }
                          },
                        ),
                      ],
                    ),
                    InkWell(
                      child: Text(
                        'Add',
                        style: SemiBoldTextStyle(16)
                            .copyWith(color: XedColors.waterMelon, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () => XError.f0(
                        _addAudio,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void onConfigApply(core.TextConfig config, bool isCancel) {
    if (!isCancel) {
      FocusScope.of(context).unfocus();
      setState(() {
        this.isEditing = false;
      });
    }
  }

  @override
  void onConfigChanged(core.TextConfig config,
      {bool textAlignChanged = false}) {
    setState(() {
      this.textConfig = config;
      if (textAlignChanged) {
        key = UniqueKey();
      }
    });
  }

  @override
  void onShowKeyboard(core.TextConfig config, bool showKeyboard) {}

  @override
  void onTapAddBlank() {}

  Widget _buildRemoveOrCancelButton() {
    return widget.model == null
        ? widget.showIconRemove
            ? InkWell(
                child: Image.asset('assets/icons/deleteRed.png'),
                onTap: () => XError.f0(() {
                  Navigator.of(context).pop();
                }),
              )
            : InkWell(
                child: Text(
                  'Cancel',
                  style: SemiBoldTextStyle(16)
                      .copyWith(color: XedColors.waterMelon, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                onTap: () => XError.f0(() {
                  Navigator.of(context).pop();
                }),
              )
        : SizedBox();
  }

  void _addAudio() {
    if (playerSubscription != null) {
      playerSubscription.cancel();
      playerSubscription = null;
    }
    if (widget.model != null) {
      widget.model.textConfig = this.textConfig;
      widget.model.text = this.textEditingController.text;
      Navigator.of(context).pop<AudioData>(
        AudioData(
          text: widget.model.text,
          file: file,
          textConfig: widget.model.textConfig,
          url: this.widget.url,
        ),
      );
    } else {
      if (widget.audioType == AudioType.Record) Navigator.of(context).pop();
      Navigator.of(context).pop<AudioData>(
        AudioData(
          text: textEditingController.text,
          file: file,
          textConfig: textConfig,
          url: this.widget.url,
        ),
      );
    }
  }
}

class AudioData {
  final String text;
  final core.TextConfig textConfig;
  final File file;
  final String url;

  AudioData({this.text, this.file, this.textConfig, this.url});
}
