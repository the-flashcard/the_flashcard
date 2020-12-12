library edit_card_screen;

import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:tf_core/tf_core.dart' as core;

import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/notification/notification_receiver.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/design_card_event.dart';
import 'package:the_flashcard/deck_creation/edit_controller.dart';
import 'package:the_flashcard/deck_creation/image/x_image_edit_component.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_creation/requestion_focus_bloc.dart';
import 'package:the_flashcard/deck_creation/scroll_controller_card_side.dart';
import 'package:the_flashcard/deck_creation/text_creation/x_text_edit_widget.dart';
import 'package:the_flashcard/deck_creation/video/x_toolbox_edit_video_component.dart';
import 'package:the_flashcard/deck_creation/x_progress_indicator.dart';
import 'package:the_flashcard/deck_screen/deck_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/onboarding/onboarding.dart';

part 'edit_card_icon_widget.dart';
part 'edit_card_onboarding.dart';

class EditCardScreen extends StatefulWidget {
  static const name = "/design_card";
  final DeckBloc bloc;
  final core.Deck deck;
  final core.Card card;

  EditCardScreen.create(this.bloc, this.deck) : card = null;

  EditCardScreen.edit(this.bloc, this.deck, core.Card card)
      : card = core.Card.from(card);

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends XState<EditCardScreen>
    with
        SingleTickerProviderStateMixin,
        OnFloatButtonCallBack,
        XColorToolBoxCallBack,
        XAlignmentToolBoxCallBack,
        OnVideoEditToolBoxCallback {
  static const _activeIconColor = XedColors.battleShipGrey;
  static const mode = XComponentMode.Review;
  static const _inactiveIconColor = Color.fromRGBO(123, 124, 125, 0.2);
  static final _bottomHeight = 75.0;
  final uploadBloc = UploadBloc();
  final swipeController = SwiperController();
  final _editControllers = <XComponentEditController>[];
  final _scrollController = ScrollControllerCardSide();
  final key = GlobalKey<ScaffoldState>();
  final RequestionFocusBloc focusBloc = RequestionFocusBloc();

  Timer timer = Timer(const Duration(milliseconds: 100), () {});
  bool _isEditMode = false;
  bool _isFrontShowing = true;
  int _currentSideIndex = 0;
  int _selectedIndex = 0;
  Offset recentTapDownOffset;
  DesignCardBloc designCardBloc;
  XFloatButton floatButtons;
  AnimationController floatButtonController;
  bool _isEditText = false;
  bool _keyBoardShowing = true;
  bool editImageShowing = false;
  core.Video currentVideo;
  bool isDownloadingImage = false;
  // bool _isFloatShowing = false;

  @override
  void initState() {
    super.initState();
    _initState();
    _scrollController.initControllers(
      widget.deck?.cardIds?.isNotEmpty == true ? widget.deck.cardIds.length : 0,
    );
  }

  void _initState() {
    DeckBloc bloc = widget.bloc;
    if (widget.card?.design == null)
      designCardBloc = DesignCardBloc.create(bloc);
    else
      designCardBloc = DesignCardBloc.edit(bloc, widget.card);

    floatButtonController = AnimationController(
      duration: Duration(milliseconds: 120),
      vsync: this,
    );
    floatButtons = XFloatButton(floatButtonController, this);
    initEditController();
  }

  void initEditController() {
    _editControllers.clear();
    int componentCount =
        designCardBloc.getComponentCount(_isFrontShowing, _currentSideIndex);
    for (var i = 0; i < componentCount; i++) {
      _editControllers.add(XComponentEditController());
    }
  }

  bool _isAllowAddFront(DesignState designState) {
    return designCardBloc.noEmptyFronts() && _isFrontShowing;
  }

  @override
  void dispose() {
    try {
      floatButtons?.closeButton();
    } catch (ex) {
      core.Log.error(ex);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Stack(
        children: <Widget>[
          Scaffold(
            key: key,
            resizeToAvoidBottomInset: false,
            backgroundColor: XedColors.bgDefault,
            appBar: AppBarWithSetting(
              bloc: designCardBloc,
              titleText: widget.deck?.name ?? "Untitled deck",
              settingSelectedCallback: _onSettingChanged,
              cancelCallBack: _onCancelPressed,
              saveCallBack: _onSavePressed,
              onTap: () => XError.f0(_hideDeleteButton),
            ),
            body: NotificationReceiver(
              child: SafeArea(
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<UploadBloc, UploadState>(
                      bloc: uploadBloc,
                      listener: _onUploadStateChanged,
                    ),
                    BlocListener<DesignCardBloc, DesignState>(
                      bloc: designCardBloc,
                      listener: _onDesignCardStateChanged,
                    )
                  ],
                  child: Stack(
                    children: [
                      BlocBuilder<UploadBloc, UploadState>(
                        bloc: uploadBloc,
                        builder: (_, state) {
                          return state is UploadingState
                              ? XProgressIndicator(percen: state.percen)
                              : SizedBox();
                        },
                      ),
                      Column(
                        children: [
                          BlocBuilder<DesignCardBloc, DesignState>(
                            bloc: designCardBloc,
                            builder: (context, designState) {
                              return Expanded(
                                child: Center(
                                  child: designCardBloc.hasFronts()
                                      ? _buildSwiper(designState)
                                      : XAddCardWizardWidget(),
                                ),
                              );
                            },
                          ),
                          _buildBottomToolboxWidgets(),
                        ],
                      ),
                      _isEditMode
                          ? Padding(
                              padding: EdgeInsets.only(top: hp(18)),
                              child: _buildDeleteCardButton(),
                            )
                          : SizedBox(),
                      BlocBuilder<DesignCardBloc, DesignState>(
                        bloc: designCardBloc,
                        builder: (context, designState) {
                          if (designState is DesignSavingState) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: XedColors.transparent,
                              child: Center(child: XedProgress.indicator()),
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                      //TODO: IMPLEMENT LOADING BASE LOADING BLOC
                      buildDownloadingImage(isDownloadingImage),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _EditCardOnboarding(nameScreen: EditCardScreen.name),
        ],
      ),
    );
  }

  Widget _buildBottomToolboxWidgets() {
    return BlocBuilder<DesignCardBloc, DesignState>(
      bloc: designCardBloc,
      builder: (context, designState) {
        return Container(
          margin: EdgeInsets.only(bottom: hp(2)),
          height: _bottomHeight,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _EditCardIconButtonWidget(
                key: GlobalKeys.flipCard,
                testDriverKey: Key(DriverKey.ICON_FLIP),
                icon: SvgPicture.asset(
                  _isFrontShowing ? Assets.icFlip : Assets.icFlipBack,
                  color: designCardBloc.hasFronts()
                      ? _activeIconColor
                      : _inactiveIconColor,
                  width: hp(30),
                  height: hp(30),
                ),
                iconForOnboarding: SvgPicture.asset(
                  _isFrontShowing ? Assets.icFlip : Assets.icFlipBack,
                  color: XedColors.white255,
                  width: hp(30),
                  height: hp(30),
                ),
                onTap: designCardBloc.hasFronts()
                    ? () => XError.f0(() {
                          designCardBloc
                              .getFlipController(_currentSideIndex)
                              ?.flip();
                        })
                    : null,
              ),
              RawMaterialButton(
                key: Key(DriverKey.ADD_NEW_FRONT),
                onPressed: _isAllowAddFront(designState)
                    ? () => XError.f0(_onAddNewCardSidePressed)
                    : null,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: hp(35.0),
                ),
                shape: CircleBorder(),
                constraints: BoxConstraints.tight(Size(wp(75), hp(75))),
                elevation: 0.0,
                fillColor: _isAllowAddFront(designState)
                    ? XedColors.waterMelon
                    : const Color.fromRGBO(253, 68, 104, 0.2),
              ),
              Builder(builder: (context) {
                return _EditCardIconButtonWidget(
                  key: GlobalKeys.editCard,
                  testDriverKey: Key(DriverKey.ICON_EDIT),
                  icon: ImageIcon(
                    AssetImage(Assets.icEditGray),
                    color: designCardBloc.hasFronts()
                        ? _activeIconColor
                        : _inactiveIconColor,
                    size: hp(30),
                  ),
                  iconForOnboarding: ImageIcon(
                    AssetImage(Assets.icEditGray),
                    color: XedColors.white255,
                    size: hp(30),
                  ),
                  onTap: designCardBloc.hasFronts()
                      ? () => XError.f0(() => _onEditModePressed(context))
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeleteCardButton() {
    return Container(
      alignment: Alignment.topCenter,
      child: RawMaterialButton(
        onPressed: () => XError.f0(
          () => _deleteCardSide(_isFrontShowing, _currentSideIndex),
        ),
        child: Image.asset(
          Assets.icDeleteWhite,
          height: hp(30),
          width: wp(30),
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints.tight(Size(wp(44), hp(44))),
        elevation: 0.0,
        fillColor: XedColors.battleShipGrey,
      ),
    );
  }

  Widget _buildSwiper(DesignState designState) {
    core.Log.debug("Card side: $_currentSideIndex");
    return Swiper(
      physics: _isFrontShowing
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
      itemCount: designCardBloc.design.getFrontCount(),
      controller: swipeController,
      viewportFraction: 0.8,
      scale: 0.95,
      loop: false,
      onIndexChanged: _onFrontSwiped,
      itemBuilder: (_, sideIndex) {
        return XFlipperWidget(
          front: _buildCard(
            isFront: true,
            sideIndex: sideIndex,
            container: designCardBloc.design.fronts[sideIndex],
            title: '#QUESTION ${sideIndex + 1}',
          ),
          back: _buildCard(
            isFront: false,
            sideIndex: sideIndex,
            container: designCardBloc.design.back,
            title: 'Answer',
          ),
          flipController: designCardBloc.getFlipController(sideIndex),
          onFlipped: _onFlipped,
          tapToFlipEnable: false,
        );
      },
    );
  }

  Widget _buildCard({
    @required bool isFront,
    @required int sideIndex,
    @required core.Container container,
    @required String title,
  }) {
    final components = container?.components ?? const <core.Component>[];
    final gradient =
        container?.toGradient() ?? core.XGradientColor.init().toGradient();
    final gradient2 = getGradientFromGradient(gradient);
    if (components.isEmpty) {
      return XAddComponentWizardWidget(title, gradient);
    } else {
      double marginHorizontal = 12;
      double marginTop = hp(25);
      double marginBottom = hp(20);
      double width = wp(275);
      double height = hp(504);
      double width27 = wp(105);
      double partPaddingTop = hp(10);

      var margin = EdgeInsets.fromLTRB(
        marginHorizontal,
        marginTop,
        marginHorizontal,
        marginBottom,
      );
      var margin2 = margin.copyWith(
        left: margin.left + margin.top / 2,
        top: hp(10),
      );

      return Stack(
        children: [
          Container(
            height: hp(30),
            width: width27,
            margin: margin2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
          SizedBox(
            height: double.infinity,
            child: Container(
              margin: margin,
              height: height,
              width: width,
              alignment: container?.toAlignment(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  partPaddingTop + hp(5),
                  10,
                  _getBottomPadding() + 10,
                ),
                child: SingleChildScrollView(
                  controller:
                      _scrollController.getController(isFront, sideIndex),
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisSize: MainAxisSize.max,
                    children: List.generate(components.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _buildWidget(
                          isFront,
                          sideIndex,
                          index,
                          components[index],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: hp(30),
            width: width27,
            margin: margin2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: gradient2,
            ),
            child: Center(
              child: AutoSizeText(
                title ?? '',
                textAlign: TextAlign.justify,
                style: BoldTextStyle(12).copyWith(
                  letterSpacing: 0.43,
                  color: gradient.colors.length > 1
                      ? XedColors.white
                      : XedColors.brownGrey,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMoreButton(bool isFront, int index) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(wp(8)),
        child: Container(
          height: wp(26),
          width: wp(26),
          decoration: BoxDecoration(
            color: Color.fromRGBO(43, 43, 43, 0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.more_horiz,
            color: XedColors.white,
            size: wp(14),
          ),
        ),
      ),
      onTapDown: (detail) => XError.f0(() {
        setState(() {
          _selectedIndex = index;
          recentTapDownOffset = detail.globalPosition;
        });
        timer.cancel();
        timer = _getTimer(isFront, index);
        _onComponentPressed(isFront, index, detail.globalPosition);
      }),
      onTapCancel: () => XError.f0(() {
        timer.cancel();
      }),
      onTap: () => XError.f0(() {
        timer.cancel();
      }),
    );
  }

  Widget _buildComponentSettingButton(bool isFront, int index) {
    return _isEditMode ? _buildMoreButton(isFront, index) : SizedBox();
  }

  Widget _buildWidget(
    bool isFront,
    int sideIndex,
    int index,
    core.Component component,
  ) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        _componentWidget(
          isFront,
          sideIndex,
          index,
          component,
        ),
        _buildComponentSettingButton(isFront, index),
      ],
    );
  }

  Widget _componentWidget(
      bool isFront, int sideIndex, int index, core.Component component) {
    switch (component.runtimeType) {
      case core.Audio:
        return XAudioPlayerWidget(
          component,
          index,
          mode: XComponentMode.Editing,
          key: designCardBloc.getKey(isFront, sideIndex, index),
        );
      case core.Text:
        return XTextEditWidget(
          key: designCardBloc.getKey(isFront, sideIndex, index),
          componentData: component,
          bloc: this.focusBloc,
          onSubmitted: (editedComponent, mode) => XError.f0(() {
            core.Log.debug("Mode throw ?? $mode");
            try {
              this._isEditText =
                  mode != EditTextMode.Done || FocusScope.of(context).hasFocus;
            } catch (ex) {
              core.Log.error(ex);
              this._isEditText = false;
            }
            if (mode == EditTextMode.Done) {
              core.Log.debug("Update component");
              _updateOrRemoveComponent(
                isFront,
                sideIndex,
                index,
                editedComponent,
              );
            }
          }),
          onTap: () => XError.f0(_onOpenEditText),
          preScreenName: EditCardScreen.name,
          onKeyboardShowing: _onKeyBoardShowing,
        );
      case core.Image:
        return XImageEditComponent(
          componentData: component,
          onEditCompleted: (editedComponent) {
            _updateOrRemoveComponent(
              isFront,
              sideIndex,
              index,
              editedComponent,
            );
          },
          key: designCardBloc.getKey(isFront, sideIndex, index),
          onTap: () => XError.f0(_onOpenEditImage),
          editing: false,
          cubit: focusBloc,
          //  editController: _editControllers[index],
          preScreenName: EditCardScreen.name,
        );
      case core.Video:
        return XVideoPlayerWidget(
          component,
          index,
          key: designCardBloc.getKey(isFront, sideIndex, index),
        );
      case core.MultiChoice:
        return XMultiChoiceWidget(
          component,
          index: index,
          key: designCardBloc.getKey(isFront, sideIndex, index),
          mode: mode,
        );
      case core.MultiSelect:
        return XMultiChoiceWidget(
          component,
          index: index,
          key: designCardBloc.getKey(isFront, sideIndex, index),
          mode: mode,
        );
      case core.FillInBlank:
        return XFIBWidget(
          componentData: component,
          index: index,
          mode: mode,
          enableHintWidget: false,
          key: designCardBloc.getKey(isFront, sideIndex, index),
        );
      case core.Dictionary:
        return XDictionaryWidget(
          component,
          index,
        );
      default:
        return SizedBox();
    }
  }

  void _onUploadStateChanged(BuildContext context, UploadState state) {
    switch (state.runtimeType) {
      case UploadFailed:
        _closeAllPopup();
        showErrorSnakeBar((state as UploadFailed).messenge, context: context);
        break;
      case VideoUploadedSuccess:
        _addComponent((state as VideoUploadedSuccess).component);
        break;
      case AudioUploadedSuccess:
        _addComponent((state as AudioUploadedSuccess).component);
        break;
      case ImageUploadedSuccess:
        _addComponent((state as ImageUploadedSuccess).component);
        break;
      case AudioUrlUploadedSuccess:
        _showAudioEditing(state);
        break;
      default:
    }
  }

  void _onDesignCardStateChanged(BuildContext context, DesignState state) {
    if (state is DesignFailureState) {
      showErrorSnakeBar(state.error, context: context);
    } else if (state is DesignCompletedState) {
      //Close this screen
      _closeThisScreen();
    } else if (state is CardSideAdded) {
      if (state.isFront) _scrollController.addControllerFront();
      //Move and swipe to the recent added card side.
      swipeController.move(state.sideIndex);
    } else if (state is CardSideRemoved) {
      if (state.isFront)
        _scrollController.removeControllerFront(state.sideIndex);
      if (designCardBloc.design.getFrontCount() <= 0) {
        _closeAllPopup();
      }
    } else if (state is ComponentMoved) {
      _closeAllPopup();
      _selectedIndex = state.toIndex;
    } else if (state is ComponentRemoved) {
      _closeAllPopup();
    } else if (state is ComponentAdded) {
      //      // delayed because wait a new component appended in tree (rebuild)
      if (mounted)
        _scrollController.moveToBottom(state.isFront, state.sideIndex);
    }
  }

  void _onFrontSwiped(int index) {
    setState(() {
      _currentSideIndex = index;
      initEditController();
      _closeAllPopup();
    });
  }

  void _onFlipped(bool isFront) {
    _isFrontShowing = isFront;
    initEditController();
    _closeAllPopup();
    setState(() {});
  }

  void _onSettingChanged(ToolboxItem settingConfig) {
    if (_isEditMode)
      setState(() {
        _isEditMode = false;
      });
    switch (settingConfig) {
      case ToolboxItem.RESET:
        _resetCardSide(_isFrontShowing, _currentSideIndex);
        break;
      case ToolboxItem.BACKGROUND:
        Gradient gradient = designCardBloc.design
            .getCardSide(_isFrontShowing, _currentSideIndex)
            ?.backgroundColor
            ?.toGradient();
        gradient != null
            ? Future.delayed(const Duration(milliseconds: 300)).then(
                (_) => key.currentState.showBottomSheet(
                  (context) => XGradientColorToolBoxWidget(
                    callBack: this,
                    configTitle: 'BACKGROUND COLOR',
                    gradientDefault: gradient,
                  ),
                ),
              )
            : SizedBox();

        break;
      case ToolboxItem.ALIGNMENT:
        int alignment = designCardBloc.design
            .getCardSide(_isFrontShowing, _currentSideIndex)
            ?.alignment;
        alignment != null
            ? Future.delayed(Duration(milliseconds: 300)).then(
                (_) => key.currentState.showBottomSheet(
                  (_) => XAlignmentToolBoxWidget(
                    alignmentDefault: core.XCardAlignment.values[alignment],
                    callBack: this,
                    configTitle: 'TEXT ALIGNMENT',
                  ),
                ),
              )
            : SizedBox();
        break;
      default:
        break;
    }
  }

  void _controlDownloadingWidget(bool visible) {
    isDownloadingImage = visible;
    setState(() {});
  }

  void _onToolboxItemSelected(ToolboxItem selectedId) async {
    core.Component component;
    switch (selectedId) {
      case ToolboxItem.TEXT:
        component = core.Text();
        _addComponent(component);
        break;

      case ToolboxItem.IMAGE:
        _closeAllPopup();
        await XChooseImagePopup(
          context: context,
          onFileSelected: (file) {
            _controlDownloadingWidget(false);
            if (file != null) dispatchUploadImage(file: file);
          },
          onDownloadingFile: () {
            _controlDownloadingWidget(true);
          },
          onCompleteDownloadFile: () {
            _controlDownloadingWidget(false);
          },
          onError: (error) {
            _controlDownloadingWidget(false);
            dispatchError();
          },
          preScreenName: EditCardScreen.name,
        ).show();
        break;

      case ToolboxItem.VIDEO:
        _closeAllPopup();
        await XChooseVideoPopup(
          context: context,
          onFileSelected: (file) {
            if (file != null) {
              uploadBloc.add(UploadVideoEvent(file));
            }
          },
          onUrlSelected: _onUrlSeleted,
          onError: (Exception value) {
            dispatchError();
          },
          preScreenName: EditCardScreen.name,
        ).show();
        break;
      case ToolboxItem.VOICE:
        _closeAllPopup();
        await XChooseAudioPopup(
          context: context,
          onAudioDataSubmitted: (data) {
            uploadBloc.add(UploadAudioEvent(data));
          },
          onError: (Exception ex) {
            if (ex is VocabularyException) {
              dispatchError(error: ex.reason);
            } else {
              dispatchError();
            }
          },
          onUrlSelected: (url, {text}) {
            if (core.UrlUtils.isFormatHtml(url)) {
              uploadBloc.add(UploadAudioUrlEvent(url, text: text));
            } else {
              dispatchError();
            }
          },
          preScreenName: EditCardScreen.name,
          onVocabularySelected: (String url, String text) {
            _addComponent(core.Audio(url: url, text: text));
          },
        ).show();
        break;
      case ToolboxItem.MULTI_CHOICE:
        _closeAllPopup();
        component = await Navigator.of(context).pushNamed(MCStepOneScreen.name)
            as core.Component;

        _addComponent(component);
        break;

      case ToolboxItem.FILL_IN_BLANK:
        _closeAllPopup();
        component = await Navigator.of(context)
            .pushNamed(FIBCreationStepOneScreen.name) as core.FillInBlank;

        _addComponent(component);
        break;
      default:
        break;
    }

    _closeAllPopup();
  }

  void _onUrlSeleted(String url) {
    if (core.VideoUtils.isYoutubeUrl(url)) {
      core.Component component = core.Video()..url = url;
      _addComponent(component);
    } else {
      dispatchError();
    }
  }

  void _onAddNewCardSidePressed() {
    designCardBloc.add(CreateCardSide(isFront: true));
  }

  void _onComponentPressed(bool isFront, int index, Offset location) {
    core.Log.debug("On pressed: $index");
    _closeAllPopup();
    floatButtons.show(context, index, location);
  }

  @override
  void onFloatingOpen(int index) {
    _selectedIndex = index;
    setState(() {});
  }

  @override
  void onFloatingClose() {
    setState(() {});
  }

  @override
  void onFloatingEdit() {
    try {
      final core.CardDesign design = designCardBloc.design;
      final core.Component component = _isFrontShowing
          ? design.getFrontComponent(_currentSideIndex, _selectedIndex)
          : design.getBackComponent(_selectedIndex);
      final Key key = designCardBloc.getKey(
        _isFrontShowing,
        _currentSideIndex,
        _selectedIndex,
      );
      editComponent(component, _selectedIndex, key);
    } catch (ex) {
      core.Log.error(ex);
    }
  }

  @override
  void onFloatingMoveDown() {
    designCardBloc.add(
      MoveDown(
          isFront: _isFrontShowing,
          sideIndex: _currentSideIndex,
          index: _selectedIndex),
    );
  }

  @override
  void onFloatingMoveUp() {
    designCardBloc.add(
      MoveUp(
          isFront: _isFrontShowing,
          sideIndex: _currentSideIndex,
          index: _selectedIndex),
    );
  }

  @override
  void onFloatingDelete() {
    designCardBloc.add(
      DeleteComponent(
        isFront: _isFrontShowing,
        sideIndex: _currentSideIndex,
        index: _selectedIndex,
      ),
    );
  }

  void _onEditModePressed(context) {
    setState(
      () {
        _isEditMode = true;

        showBottomSheet(
            context: context,
            builder: (context) {
              return XToolboxWidget(
                title: 'ADD/EDIT',
                configs: _isFrontShowing ? frontToolboxItems : backToolboxItems,
                callback: _onToolboxItemSelected,
              );
            }).closed.whenComplete(
          () {
            if (_isEditMode)
              setState(() {
                _isEditMode = false;
              });
          },
        );
      },
    );
  }

  void _deleteCardSide(bool isFront, int sideIndex) {
    designCardBloc.add(
      DeleteCardSide(
        isFront: isFront,
        sideIndex: sideIndex,
      ),
    );
  }

  void _resetCardSide(bool isFront, int sideIndex) {
    designCardBloc.add(
      ResetCardSide(
        isFront: isFront,
        sideIndex: sideIndex,
      ),
    );
    setState(() {
      _isEditMode = false;
    });
  }

  void _addComponent(core.Component component) {
    if (component != null) {
      designCardBloc.add(
        AddComponent(
          isFront: _isFrontShowing,
          sideIndex: _currentSideIndex,
          componentData: component,
        ),
      );
      setState(() {
        _isEditMode = false;
      });
    }
  }

  void _updateOrRemoveComponent(
    bool isFront,
    int currentSideIndex,
    int index,
    core.Component component,
  ) {
    _isEditMode = false;
    if (component != null) {
      designCardBloc.add(
        UpdateComponent(
          isFront: isFront,
          sideIndex: currentSideIndex,
          index: index,
          componentData: component,
        ),
      );
    } else {
      designCardBloc.add(
        DeleteComponent(
          isFront: isFront,
          sideIndex: currentSideIndex,
          index: index,
        ),
      );
    }
    if (component is core.Image) this.editImageShowing = false;
  }

  void _onSavePressed() {
    designCardBloc.add(SaveDesign(widget.deck.id));
  }

  void _closeAllPopup() {
    closeUntil(EditCardScreen.name);
  }

  void _closeThisScreen() {
    closeScreen(EditCardScreen.name);
  }

  void _onCancelPressed() async {
    try {
      if (FocusScope.of(context).hasFocus) {
        _closeAllPopup();
      }
    } catch (ex) {
      core.Log.error(ex);
    }
    if (designCardBloc.hasChanges()) {
      bool yes = await showModalBottomSheet(
        context: context,
        builder: (context) => XConfirmPopup(
          title: core.Config.getString("msg_discard_change"),
          description: "",
        ),
      );

      if (yes ?? false) {
        _closeThisScreen();
      }
    } else {
      _closeThisScreen();
    }
  }

  Future<bool> _onBackPressed() async {
    try {
      if (FocusScope.of(context).hasFocus) {
        _closeAllPopup();
      }
    } catch (ex) {
      core.Log.error(ex);
    }
    if (designCardBloc.hasChanges()) {
      bool yes = await showModalBottomSheet(
        context: context,
        builder: (context) => XConfirmPopup(
          title: core.Config.getString("msg_discard_change"),
          description: "",
        ),
      );

      if (yes ?? false) {
        _closeAllPopup();
        return Future<bool>.value(true);
      } else {
        return Future<bool>.value(false);
      }
    }

    return Future<bool>.value(true);
  }

  void editComponent(
      core.Component component, int selectedIndex, Key key) async {
    switch (component.runtimeType) {
      case core.Audio:
        core.Audio newComponent = await navigateToScreen(
          screen: AudioEditingScreen.edit(
            model: component,
            audioType: AudioType.Url,
          ),
          name: AudioEditingScreen.name,
        ) as core.Audio;
        // newComponent is null -> cancel
        if (newComponent != null) updateComponent(newComponent);

        break;

      case core.Text:
        _closeAllPopup();
        focusBloc.add(RequestionFocusTextEvent(key));
        // _editControllers[selectedIndex]?.edit();
        break;
      case core.Image:
        // _editControllers[selectedIndex]?.edit();
        break;
      case core.Video:
        currentVideo = component;
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return XToolboxEditVideoComponent(
                defaultConfig:
                    (component as core.Video).config ?? core.VideoConfig.init(),
                callback: this,
              );
            });
        break;
      case core.MultiChoice:
        core.MultiChoice newComponent = await navigateToScreen(
          screen: MCStepOneScreen.edit(component: component),
          name: MCStepOneScreen.name,
        ) as core.MultiChoice;
        // newComponent is null -> cancel
        if (newComponent != null) updateComponent(newComponent);

        break;

      case core.MultiSelect:
        core.MultiChoice newComponent = await navigateToScreen(
          screen: MCStepOneScreen.edit(component: component),
          name: MCStepOneScreen.name,
        ) as core.MultiChoice;

        // newComponent is null -> cancel
        if (newComponent != null) updateComponent(newComponent);

        break;

      case core.FillInBlank:
        core.FillInBlank newComponent = await navigateToScreen(
          screen: FIBCreationStepOneScreen.edit(model: component),
          name: FIBCreationStepOneScreen.name,
        ) as core.FillInBlank;
        // newComponent is null -> cancel
        if (newComponent != null) updateComponent(newComponent);

        break;
      case core.Dictionary:
        break;

      default:
        break;
    }
  }

  void updateComponent(core.Component newComponent) {
    designCardBloc.add(
      UpdateComponent(
        componentData: newComponent,
        sideIndex: _currentSideIndex,
        isFront: _isFrontShowing,
        index: _selectedIndex,
      ),
    );
  }

  ///ON COLOR CHANGED
  @override
  void applyChanged() {
    //?????
    _closeAllPopup();
  }

  @override
  void cancelChanged(LinearGradient oldValue) {
    designCardBloc.add(UpdateColorCardSide(
      background: oldValue,
      sideIndex: _currentSideIndex,
      isFront: _isFrontShowing,
    ));
    _closeAllPopup();
  }

  @override
  void onColorChange(LinearGradient value) {
    designCardBloc.add(UpdateColorCardSide(
      background: value,
      sideIndex: _currentSideIndex,
      isFront: _isFrontShowing,
    ));
  }

  @override
  void backPressed() {
    _closeAllPopup();
    _openCardSideSettingPopup();
  }

  /// Alignment Changed

  @override
  void alignmentChanged(core.XCardAlignment value) {
    designCardBloc.add(UpdateAlignmentCardSide(
      alignment: value,
      sideIndex: _currentSideIndex,
      isFront: _isFrontShowing,
    ));
  }

  @override
  void applyAlignmentChanged() {
    _closeAllPopup();
  }

  @override
  void backAlignmentPressed() {
    _openCardSideSettingPopup();
  }

  @override
  void cancelAlignmentChanged(core.XCardAlignment oldValue) {
    designCardBloc.add(
      UpdateAlignmentCardSide(
        alignment: oldValue,
        sideIndex: _currentSideIndex,
        isFront: _isFrontShowing,
      ),
    );
    _closeAllPopup();
  }

  void _openCardSideSettingPopup() {
    _closeAllPopup();
    Future.delayed(Duration(milliseconds: 300)).then(
      (_) => key.currentState.showBottomSheet(
        (context) {
          return XToolboxWidget(
            title: 'SETTING',
            configs: AppBarWithSetting.settingModels,
            callback: (id) {
              _closeAllPopup();
              _onSettingChanged(id);
            },
          );
        },
      ),
    );
  }

  void _hideDeleteButton() {
    if (_isEditMode)
      setState(
        () {
          _isEditMode = false;
        },
      );
  }

  void _onOpenEditImage() {
    _hideDeleteButton();
    this.editImageShowing = true;
    core.Log.debug(this.editImageShowing);
  }

  void _onOpenEditText() {
    _hideDeleteButton();
    this._isEditText = true;
    editImageShowing = false;
    reRender();
  }

  void dispatchUploadImage({File file}) {
    uploadBloc.add(UploadImageEvent(file));
  }

  void dispatchError({String error = 'Error!. Try again!'}) {
    uploadBloc.add(UploadErrorEvent(error));
  }

  double _getBottomPadding() {
    try {
      if (_isEditText) {
        final double hp40 = hp(40);
        final double bottom = _keyBoardShowing
            ? MediaQuery.of(context).viewInsets.bottom > hp40
                ? MediaQuery.of(context).viewInsets.bottom - hp40
                : hp40
            : hp(230);

        return bottom > 0 ? bottom : hp40;
      } else {
        return 0;
      }
    } catch (ex) {
      core.Log.error(ex);
      return 0;
    }
  }

  Timer _getTimer(bool isFront, int index) {
    return Timer(const Duration(milliseconds: 250), () {
      _onComponentPressed(isFront, index, recentTapDownOffset);
    });
  }

  void _onKeyBoardShowing(bool value) {
    this._keyBoardShowing = value;
    this._isEditText = true;
    setState(() {});
  }

  @override
  void onCancel(core.VideoConfig config) {
    _closeAllPopup();
  }

  @override
  void onChanged(core.VideoConfig config) {
    if (this.currentVideo != null) {
      this.currentVideo.config = config;
      designCardBloc.add(
        UpdateComponent(
          isFront: _isFrontShowing,
          sideIndex: _currentSideIndex,
          index: _selectedIndex,
          componentData: this.currentVideo,
        ),
      );
      // setState(() {});
    }
  }

  @override
  void onDone(core.VideoConfig config) {
    _closeAllPopup();
  }

  @override
  void onIconHeightPress(bool isOn) {}

  void _showAudioEditing(AudioUrlUploadedSuccess state) async {
    AudioData audioData = await navigateToScreen<AudioData>(
      screen: AudioEditingScreen.inputUrl(
        url: state.url,
        showInputTextField: true,
        showIconRemove: false,
        text: state.text,
      ),
      name: AudioCreationScreen.name,
    );
    if (audioData != null) {
      uploadBloc.add(AudioUploadedSuccessEvent(
        null,
        audioData,
        passConfiglink: true,
      ));
    }
  }
}
