import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_step_one_bloc.dart';
import 'package:the_flashcard/deck_creation/multi_choice/mc_step_two_screen.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';
import 'package:the_flashcard/deck_creation/upload_bloc.dart';
import 'package:the_flashcard/deck_creation/upload_state.dart' as dc;
import 'package:the_flashcard/deck_creation/x_progress_indicator.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class MCStepOneScreen extends StatefulWidget {
  static String name = '/deckMultiCreationOne';
  final core.MultiChoice model;

  MCStepOneScreen.create({Key key})
      : model = null,
        super(key: key);

  MCStepOneScreen.edit({Key key, core.MultiChoice component})
      : model = core.MultiChoice.fromJson((component.toJson())),
        super(key: key);

  @override
  _MCStepOneScreenState createState() => _MCStepOneScreenState();
}

class _MCStepOneScreenState extends XState<MCStepOneScreen>
    with OnTextToolBoxCallBack {
  final node = FocusNode();
  final controller = TextEditingController();
  final questionNode = FocusNode();
  final uploadBloc = UploadBloc();
  FocusedState stateFocused;

  MCStepOneBloc bloc;
  FocusedState _saveState;
  UniqueKey key = UniqueKey();
  Key keyTextField = UniqueKey();

  @override
  void initState() {
    super.initState();
    bloc = widget.model == null
        ? MCStepOneBloc.create()
        : MCStepOneBloc.edit(widget.model);
    controller.text = bloc.model.question;
  }

  @override
  void dispose() {
    node.dispose();
    controller.dispose();
    questionNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = hp(120);
    final double spacer = hp(44);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<MCStepOneBloc>(create: (_) => bloc),
          BlocProvider<UploadBloc>(create: (_) => uploadBloc),
        ],
        child: SafeArea(
          child: MultiBlocListener(
            listeners: <BlocListener>[
              BlocListener(
                cubit: bloc,
                listener: (_, state) {
                  if (state is RequestionNextScreen) {
                    Navigator.of(_).push(
                      MaterialPageRoute(
                        builder: (_) => MCStepTwoScreen(state.answers),
                      ),
                    );
                  } else if (state is UnfocusedState) {
                    stateFocused = null;

                    try {
                      if (FocusScope.of(context).hasFocus)
                        FocusScope.of(context).unfocus();
                    } catch (ex) {
                      core.Log.error(ex);
                    }
                  } else if (state is FocusedState) {
                    stateFocused = state;
                  }
                },
              ),
              BlocListener<UploadBloc, dc.UploadState>(
                cubit: uploadBloc,
                listener: _onUploadStateChanged,
              ),
            ],
            child: Stack(
              children: [
                AppbarStepOne(text: 'Create content'),
                BlocBuilder<UploadBloc, UploadState>(
                  cubit: uploadBloc,
                  builder: (_, state) {
                    return Padding(
                      padding: EdgeInsets.only(top: hp(51)),
                      child: state is UploadingState
                          ? XProgressIndicator(percen: state.percen)
                          : SizedBox(),
                    );
                  },
                ),
                Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(8, hp(65), 8, 0),
                        child: Flex(
                          mainAxisSize: MainAxisSize.min,
                          direction: Axis.vertical,
                          children: <Widget>[
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              constraints: BoxConstraints(maxHeight: height),
                              child: TextFieldQuestionWidget(
                                key: keyTextField,
                                keyValue: DriverKey.MULTI_QUESTION,
                                focusNode: questionNode,
                                controller: controller,
                                style: bloc.model.textConfig.toTextStyle(),
                                textAlign: bloc.model.textConfig.toTextAlign(),
                                hintText: 'Ask a question…',
                                hintStyle: SemiBoldTextStyle(16).copyWith(
                                  color: XedColors.battleShipGrey,
                                ),
                                onChanged: (str) => XError.f0(() {
                                  bloc.add(EditingQuestionEvent(str));
                                }),
                                onTap: () => XError.f0(() {
                                  bloc.add(
                                    FocusedEvent(
                                      node: questionNode,
                                      textConfig: this.bloc.model.textConfig,
                                      onConfigChanged: (core.TextConfig value,
                                          bool textAlignChanged) {
                                        this.bloc.model.textConfig = value;
                                        if (textAlignChanged)
                                          keyTextField = UniqueKey();
                                        setState(() {});
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Expanded(child: AnswerListWidget()),
                            // SizedBox(height: spacer),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: BlocBuilder<MCStepOneBloc, MCState>(
                                cubit: bloc,
                                // condition: (_, state) {
                                //   return state is InitState ||
                                //       state is QuestionFocused ||
                                //       state is QuestionUnfocused;
                                // },
                                builder: (_, state) {
                                  return stateFocused is FocusedState
                                      ? SizedBox()
                                      : SizedBox(height: spacer);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: BlocBuilder<MCStepOneBloc, MCState>(
                        cubit: bloc,
                        // condition: (_, state) {
                        //   return state is InitState ||
                        //       state is QuestionFocused ||
                        //       state is QuestionUnfocused;
                        // },
                        builder: (_, state) {
                          return stateFocused is FocusedState
                              ? _buildTextEditBottomBar(stateFocused)
                              : SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocBuilder<MCStepOneBloc, MCState>(
                    cubit: bloc,
                    builder: (_, state) {
                      return stateFocused is FocusedState
                          ? SizedBox()
                          : _buildBottomBar();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: XedColors.waterMelon,
      width: double.infinity,
      child: BottomActionBarWidget(
        onTapRight: () => XError.f0(_next),
        next: bloc.nextState is RequestionNextOn,
        onTapLeft: () => XError.f0(() {
          Navigator.of(context).pop(null);
        }),
      ),
    );
  }

  void _next() {
    bloc.add(RequestionNextEvent());
  }

  @override
  void onConfigApply(core.TextConfig config, bool isCancel) {
    if (!isCancel) {
      FocusScope.of(context).unfocus();
      Future.delayed(Duration(milliseconds: 300)).then((_) {
        this.bloc.add(UnfocusedEvent());
      });
    }
  }

  @override
  void onConfigChanged(core.TextConfig config,
      {bool textAlignChanged = false}) {
    this.bloc.focused.onConfigChanged(config, textAlignChanged);
  }

  @override
  void onShowKeyboard(core.TextConfig config, bool showKeyboard) {}

  Widget _buildTextEditBottomBar(FocusedState state) {
    if (_saveState != state) key = UniqueKey();
    _saveState = state;
    return XToolboxEditTextWidget(
      key: key,
      defaultConfig: state.config,
      callback: this,
      focusNode: state.node,
      // listener: listener,
    );
  }

  @override
  void onTapAddBlank() {}

  void _onUploadStateChanged(BuildContext context, UploadState state) {
    switch (state.runtimeType) {
      case UploadFailed:
        showErrorSnakeBar((state as UploadFailed).messenge, context: context);
        break;

      case AudioUrlUploadedSuccess:
        _showAudioEditing(state);
        break;
      default:
    }
  }

  void _showAudioEditing(AudioUrlUploadedSuccess state) async {
    AudioData audioData = await navigateToScreen<AudioData>(
      screen: AudioEditingScreen.inputUrl(
        url: state.url,
        showInputTextField: false,
        showIconRemove: false,
      ),
      name: AudioCreationScreen.name,
    );
    if (audioData != null) {
      uploadBloc.add(
        AudioUploadedSuccessEvent(
          null,
          audioData,
          passConfiglink: true,
          key: state.key,
        ),
      );
    }
  }
}
