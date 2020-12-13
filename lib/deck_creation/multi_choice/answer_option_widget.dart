library answer_option;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/audio_creation/audio_editing_screen.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_creation/multi_choice/button_white_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/iconbutton_remove.dart';
import 'package:the_flashcard/deck_creation/multi_choice/mc_step_one_screen.dart';
import 'package:the_flashcard/deck_creation/multi_choice/textfield_question_widget.dart';
import 'package:the_flashcard/environment/driver_key.dart';

part 'image_view.dart';

class AnswerOptionWidget extends StatefulWidget {
  final core.Answer answer;

  AnswerOptionWidget({Key key, @required this.answer}) : super(key: key);

  @override
  _AnswerOptionwidget createState() => _AnswerOptionwidget();
}

class _AnswerOptionwidget extends XState<AnswerOptionWidget> {
  int index;
  MCStepOneBloc bloc;
  UploadBloc uploadBloc;
  bool hasBottomClear;
  bool hasImage = false;
  bool hasAudio = false;
  static const image = const AssetImage("assets/images/componentImgBlack.png");
  static const audio =
      const AssetImage("assets/images/componentVoiceBlack.png");
  final node = FocusNode();
  final _key = UniqueKey();
  final controller = TextEditingController();
  Key textfieldKey = UniqueKey();
  final multiComponents = <Widget>[];
  bool isDownloadingImage = false;

  @override
  void initState() {
    super.initState();
    _initBloc();
    _initDefaultValue();
    _initComponent();
    MCState currentState = bloc.state;
    if (currentState is AddAnswerOption &&
        currentState.component == this.widget.answer) {
      _focusAnswer();
    }
  }

  bool getValue(String url) => url?.isNotEmpty == true ? true : false;

  void _initBloc() {
    bloc = BlocProvider.of<MCStepOneBloc>(context);
    uploadBloc = BlocProvider.of<UploadBloc>(context);
  }

  void _initDefaultValue() {
    index = bloc.answers.indexOf(widget.answer) + 1;
    hasBottomClear = index > 1;
    controller..text = widget.answer.text;
    hasImage = getValue(widget.answer.imageUrl);
    hasAudio = getValue(widget.answer.audioUrl);
  }

  void _initComponent() {
    final double height = hp(111);
    multiComponents.clear();

    if (hasAudio) {
      multiComponents.add(
        _AudioWidget(
          height: height,
          onTap: () => XError.f0(_removeAudioComponent),
          link: widget.answer.audioUrl,
        ),
      );
    }

    if (hasImage) {
      multiComponents.add(
        _ImageWidget(
          height: height,
          onTap: () => XError.f0(_removeImageComponent),
          link: widget.answer.imageUrl,
        ),
      );
    }
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    index = bloc.answers.indexOf(widget.answer) + 1;
    return BlocListener<UploadBloc, UploadState>(
      cubit: uploadBloc,
      listener: _onUploadStateChanged,
      child: hasBottomClear
          ? Stack(
              children: <Widget>[
                _buildOptionComponent(),
                _buildIconDelete(),
              ],
            )
          : _buildOptionComponent(),
    );
  }

  Widget _buildIconDelete() {
    return Container(
      alignment: Alignment.topRight,
      child: InkWell(
        onTap: () => XError.f0(_onDelete),
        child: IconButtonRemove(size: 24, iconSize: 14),
      ),
    );
  }

  Widget _buildOptionComponent() {
    TextStyle regularOsloGrey = RegularTextStyle(14).copyWith(
      color: XedColors.battleShipGrey,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 14, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: XedColors.duckEggBlueColor),
          color: XedColors.whiteTwoColor,
        ),
        child: Stack(
          children: <Widget>[
            Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFieldQuestionWidget(
                  key: textfieldKey,
                  keyValue: DriverKey.COMP_ANSWER + "_$index",
                  focusNode: node,
                  textAlign: widget.answer.textConfig.toTextAlign(),
                  controller: controller,
                  hintText: 'Option $index…',
                  hintStyle: regularOsloGrey,
                  style: widget.answer.textConfig.toTextStyle(),
                  onChanged: (str) => XError.f0(() {
                    widget.answer.text = str;
                    bloc.add(EditingAnswerEvent(str, widget.answer));
                  }),
                  onTap: () => XError.f0(() {
                    _focusAnswer();
                  }),
                ),
                _buildImageAndAudio(),
                hasAudio && hasImage
                    ? SizedBox(height: hp(15))
                    : Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 15),
                        height: hp(30),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Spacer(),
                            hasImage
                                ? SizedBox()
                                : Builder(
                                    builder: (context) {
                                      return ButtonWhiteWidget(
                                        icon: image,
                                        onTap: () => XError.f1<BuildContext>(
                                          _addImageComponent,
                                          context,
                                        ),
                                      );
                                    },
                                  ),
                            SizedBox(width: wp(10)),
                            hasAudio
                                ? SizedBox()
                                : ButtonWhiteWidget(
                                    icon: audio,
                                    onTap: () => XError.f1<BuildContext>(
                                      _addAudioComponent,
                                      context,
                                    ),
                                  ),
                          ],
                        ),
                      ),
              ],
            ),
            _buildImage(isDownloadingImage)
          ],
        ),
      ),
    );
  }

  Widget _buildImage(bool vissble) {
    return vissble ? Center(child: XedProgress.indicator()) : SizedBox();
  }

  void _controlDownloadingWidget(bool visible) {
    isDownloadingImage = visible;
    setState(() {});
  }

  void _addImageComponent(BuildContext context) async {
    await XChooseImagePopup(
      context: context,
      onFileSelected: (file) {
        _controlDownloadingWidget(false);
        if (file != null) {
          dispatchUploadImage(file: file);
        }
      },
      onDownloadingFile: () {
        _controlDownloadingWidget(true);
      },
      onCompleteDownloadFile: () {
        _controlDownloadingWidget(false);
      },
      onError: (Exception value) {
        _controlDownloadingWidget(false);
        dispatchError();
      },
      preScreenName: MCStepOneScreen.name,
    ).show();

    if (Navigator.of(context).canPop()) closeUntil(MCStepOneScreen.name);
  }

  void dispatchError() {
    uploadBloc.add(ErrorEvent());
  }

  void _addAudioComponent(BuildContext context) async {
    core.Log.debug('Hello');
    await XChooseAudioPopup(
      context: context,
      showInputTextField: false,
      onError: (Exception value) {
        dispatchError();
      },
      onAudioDataSubmitted: (AudioData data) {
        if (data?.file != null) dispatchUploadAudio(data);
      },
      onUrlSelected: _onUrlSelected,
      preScreenName: MCStepOneScreen.name,
      onVocabularySelected: (String url, String text) {
        final AudioUploadedSuccess state =
            AudioUploadedSuccess(core.Audio(text: text, url: url), key: _key);
        _createAndDispatchAudioComponent(state);
      },
    ).show();

    if (Navigator.of(context).canPop()) closeUntil(MCStepOneScreen.name);
  }

  void _removeAudioComponent() {
    setState(() {
      hasAudio = false;
      multiComponents.removeWhere((item) => item is _AudioWidget);
    });
    widget.answer.audioUrl = null;
    bloc.add(RemoveAudioEvent(widget.answer));
  }

  void _removeImageComponent() {
    setState(() {
      hasImage = false;

      multiComponents.removeWhere((item) => item is _ImageWidget);
    });

    widget.answer.imageUrl = null;
    bloc.add(RemoveImangeEvent(widget.answer));
  }

  Widget _buildImageAndAudio() {
    return multiComponents.isNotEmpty
        ? GridView.builder(
            shrinkWrap: true,
            itemCount: multiComponents.length,
            itemBuilder: (_, int index) => multiComponents[index],
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 9.0,
              childAspectRatio: 4 / 3,
            ),
          )
        : SizedBox();
  }

  void _onDelete() {
    bloc.add(DeleteAnswerOptionEvent(widget));
  }

  void _onUploadStateChanged(BuildContext _, UploadState state) {
    switch (state.runtimeType) {
      case AudioUploadedSuccess:
        _createAndDispatchAudioComponent(state);
        break;
      case ImageUploadedSuccess:
        _createAndDispatchImageComponent(state);
        break;

      default:
    }
  }

  void _createAndDispatchAudioComponent(AudioUploadedSuccess state) {
    if (state.key == _key && !hasAudio) {
      final double height = hp(111);
      widget.answer.audioUrl = state.component.url;
      multiComponents.add(
        _AudioWidget(
          height: height,
          onTap: () => XError.f0(_removeAudioComponent),
          link: state.component.url,
        ),
      );

      setState(() {
        hasAudio = true;
      });
      bloc.add(AddAudioEvent(this.widget.answer));
    }
  }

  void _createAndDispatchImageComponent(ImageUploadedSuccess state) {
    if (state.key == _key && !hasImage) {
      widget.answer.imageUrl = state.component.url;
      final double height = hp(111);

      multiComponents.add(
        _ImageWidget(
          height: height,
          onTap: () => XError.f0(_removeImageComponent),
          link: widget.answer.imageUrl,
        ),
      );
      setState(() {
        hasImage = true;
      });
      bloc.add(AddImangeEvent(this.widget.answer));
    }
  }

  void dispatchUploadAudio(AudioData audioData) {
    uploadBloc.add(UploadAudioEvent(audioData, key: _key));
  }

  void dispatchUploadImage({File file}) {
    uploadBloc.add(UploadImageEvent(file, key: _key));
  }

  void _focusAnswer() {
    bloc.add(
      FocusedEvent(
        node: node,
        textConfig: widget.answer.textConfig,
        onConfigChanged: (core.TextConfig value, bool textAlignChanged) {
          widget.answer.textConfig = value;
          if (textAlignChanged) {
            textfieldKey = UniqueKey();
          }
          setState(() {});
        },
      ),
    );
  }

  void _onUrlSelected(String url) {
    if (core.UrlUtils.isFormatHtml(url)) {
      uploadBloc.add(UploadAudioUrlEvent(url, key: _key));
    } else {
      dispatchError();
    }
  }
}

Widget _iconRemove({VoidCallback onTap}) {
  return Container(
    alignment: Alignment.topRight,
    margin: const EdgeInsets.only(top: 5, right: 8),
    child: InkWell(
      onTap: () => XError.f0(onTap),
      child: IconButtonRemove(size: 20, iconSize: 14),
    ),
  );
}

class _AudioWidget extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onTap;
  final String link;

  const _AudioWidget({Key key, this.height, this.width, this.onTap, this.link})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double sizeIconPlay = hp(50);
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: XedColors.waterMelon.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: sizeIconPlay,
            height: sizeIconPlay,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: XedColors.black.withAlpha(204),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.play_arrow,
              size: 30,
              color: XedColors.white,
            ),
          ),
        ),
        _iconRemove(onTap: onTap),
      ],
    );
  }
}

class _ImageWidget extends StatelessWidget {
  final double height;
  final double width;
  final VoidCallback onTap;
  final String link;

  const _ImageWidget({Key key, this.height, this.width, this.onTap, this.link})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _ImageView(
          width: width,
          height: height,
          fit: BoxFit.cover,
          radius: 10,
          url: link,
        ),
        _iconRemove(onTap: onTap),
      ],
    );
  }
}
