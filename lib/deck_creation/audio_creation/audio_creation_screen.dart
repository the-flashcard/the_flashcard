import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/audio_creation/audio_editing_screen.dart';
import 'package:wave_progress_bars/wave_progress_bars.dart';

class AudioCreationScreen extends StatefulWidget {
  static const name = '/AudioCreationScreen';
  final bool showInputTextField;

  const AudioCreationScreen({Key key, this.showInputTextField = true})
      : super(key: key);

  @override
  _AudioCreationScreenState createState() => _AudioCreationScreenState();
}

class _AudioCreationScreenState extends XState<AudioCreationScreen> {
  double recorderHeight = 96;
  double recorderTimeTextSize = 0;
  double recorderButtonSize = 54;
  double recorderWaveHeight = 0;
  double recorderInstructionTextSize = 14;
  double recorderInfoBoxOpacity = 0;
  double recorderInfoBoxHeight = 0;
  List<Color> recorderWaveColors = [XedColors.black, XedColors.black];
  MainAxisAlignment recorderAlignment = MainAxisAlignment.center;
  Duration animationDuration = Duration(milliseconds: 250);
  FlutterSound audioRecorder;
  String audioName;
  String audioResult;
  StreamSubscription recorderSubscription;
  String recorderText = '00:00:00';
  final List<double> waveRecord = [];
  Directory directory;

  @override
  void initState() {
    super.initState();
    audioRecorder = FlutterSound();
    var rng = Random();
    for (var i = 0; i < 100; i++) {
      waveRecord.add(rng.nextInt(70) * 1.0);
    }
  }

  Future<void> startRecorder() async {
    try {
      setState(() {
        recorderHeight = 238;
        recorderButtonSize = 24;
        recorderTimeTextSize = 18;
        recorderWaveHeight = 50;
        recorderAlignment = MainAxisAlignment.spaceEvenly;
        recorderWaveColors = [XedColors.roseRed, XedColors.waterMelon];
        recorderInstructionTextSize = 0;
        recorderInfoBoxOpacity = 1;
        recorderInfoBoxHeight = 429;
      });
      directory = await getTemporaryDirectory();
      audioName = 'audio.m4a';
      await audioRecorder.startRecorder(uri: '${directory.path}/$audioName');

      recorderSubscription =
          audioRecorder.onRecorderStateChanged.listen((data) {
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(data.currentPosition.toInt());
        setState(() {
          recorderText = DateFormat('mm:ss:SS').format(date).substring(0, 8);
        });
      });
    } catch (error) {
      core.Log.debug('startRecorder error: $error');
    }
  }

  Future<void> stopRecorder() async {
    try {
      audioResult = await audioRecorder.stopRecorder();
      setState(() {
        recorderHeight = 96;
        recorderButtonSize = 54;
        recorderTimeTextSize = 0;
        recorderWaveHeight = 0;
        recorderAlignment = MainAxisAlignment.center;
        recorderWaveColors = [XedColors.black, XedColors.black];
        recorderInstructionTextSize = 14;
        recorderInfoBoxOpacity = 0;
        recorderInfoBoxHeight = 0;
        recorderText = '00:00:00';
      });
      if (recorderSubscription != null) {
        recorderSubscription.cancel();
        recorderSubscription = null;
      }
      navigateToScreen(
        screen: AudioEditingScreen.record(
          audioName: audioName,
          showInputTextField: widget.showInputTextField,
        ),
        name: AudioEditingScreen.name,
      );
    } catch (error) {
      core.Log.debug(error);
    }
  }

  BoxDecoration recorderButtonDecoration() {
    return audioRecorder.isRecording
        ? BoxDecoration(
            color: XedColors.waterMelon,
            borderRadius: BorderRadius.circular(hp(4)),
          )
        : BoxDecoration(
            color: XedColors.waterMelon,
            borderRadius: BorderRadius.circular(hp(27)),
          );
  }

  Widget recorderBox() {
    return AnimatedContainer(
      color: XedColors.black,
      height: hp(recorderHeight),
      alignment: Alignment.center,
      duration: animationDuration,
      child: InkWell(
        onTap: () => XError.f0(() async {
          audioRecorder.isRecording
              ? await stopRecorder()
              : await startRecorder();
        }),
        child: Column(
          mainAxisAlignment: recorderAlignment,
          children: <Widget>[
            AnimatedContainer(
              duration: animationDuration,
              child: Text(
                recorderText,
                style: RegularTextStyle(recorderTimeTextSize)
                    .copyWith(color: XedColors.battleShipGrey),
              ),
            ),
            AnimatedContainer(
              duration: animationDuration,
              height: recorderWaveHeight,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 27,
                child: WaveProgressBar(
                  progressPercentage: 100,
                  listOfHeights: waveRecord,
                  width: MediaQuery.of(context).size.width,
                  initalColor: Colors.transparent,
                  progressColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.black,
                  timeInMilliSeconds: 15000,
                ),
              ),
            ),
            Container(
              height: hp(60),
              width: hp(60),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: XedColors.black,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AnimatedContainer(
                width: hp(recorderButtonSize),
                height: hp(recorderButtonSize),
                decoration: recorderButtonDecoration(),
                duration: animationDuration,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                            onPressed: () =>
                                XError.f0(Navigator.of(context).pop),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SvgPicture.asset('assets/images/bg_voice.svg'),
                  SizedBox(height: hp(15)),
                  Text(
                    core.Config.getString("msg_tap_record_button"),
                    style: RegularTextStyle(recorderInstructionTextSize)
                        .copyWith(color: XedColors.battleShipGrey),
                  ),
                ],
              ),
              recorderBox(),
            ],
          ),
          AnimatedContainer(
            duration: animationDuration,
            height: hp(recorderInfoBoxHeight),
            child: AnimatedOpacity(
              duration: animationDuration,
              opacity: recorderInfoBoxOpacity,
              child: Container(
                color: Color.fromARGB(179, 43, 43, 43),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
