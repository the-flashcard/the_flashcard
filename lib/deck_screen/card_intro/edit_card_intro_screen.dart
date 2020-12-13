import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/widgets/x_float_button.dart';
import 'package:the_flashcard/common/xwidgets/x_state.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/image/x_image_edit_component.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_creation/requestion_focus_bloc.dart';
import 'package:the_flashcard/deck_creation/scroll_controller_card_side.dart';
import 'package:the_flashcard/deck_creation/text_creation/x_text_edit_widget.dart';
import 'package:the_flashcard/deck_creation/x_progress_indicator.dart';
import 'package:the_flashcard/deck_screen/card_intro/add_component_introduction.dart';
import 'package:the_flashcard/deck_screen/card_intro/icon_back.dart';
import 'package:the_flashcard/deck_screen/deck_bloc.dart';
import 'package:the_flashcard/deck_screen/deck_edit_screen.dart';

class EditCardIntroScreen extends StatefulWidget {
  static const name = '/deck_introduction_screen';
  final DeckBloc bloc;

  const EditCardIntroScreen({Key key, this.bloc}) : super(key: key);

  @override
  _EditCardIntroScreenState createState() => _EditCardIntroScreenState();
}

class _EditCardIntroScreenState extends XState<EditCardIntroScreen>
    with SingleTickerProviderStateMixin, OnFloatButtonCallBack {
  final mode = XComponentMode.Review;

  int _selectedIndex = 0;
  Offset recentTapDownOffset;
  XFloatButton floatButtons;
  AnimationController floatButtonController;
  DeckBloc bloc;
  core.Container design;
  final uploadBloc = UploadBloc();
  Timer timer = Timer(const Duration(milliseconds: 100), () {});

  bool onEditImageShowing = false;

  bool _isEditText = false;
  bool _isEditMode = false;
  bool _keyBoardShowing = true;
  final List<Key> keys = <Key>[];
  final _scrollController = ScrollControllerCardSide();
  final RequestionFocusBloc focusBloc = RequestionFocusBloc();
  bool isDownloadingImage = false;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
    design = bloc.state.deck?.design != null
        ? core.Container.fromJson(bloc.state.deck.design.toJson())
        : core.Container();
    floatButtonController = AnimationController(
      duration: Duration(milliseconds: 120),
      vsync: this,
    );
    floatButtons = XFloatButton(floatButtonController, this);

    keys.addAll(List.generate(design.getComponentCount(), (i) => UniqueKey()));
  }

  @override
  void dispose() {
    try {
      keys.clear();
      floatButtons?.closeButton();
    } catch (ex) {
      core.Log.error(ex);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    core.Log.debug(MediaQuery.of(context).viewInsets.bottom);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: XedColors.whiteTwoColor,
      appBar: AppBar(
        backgroundColor: XedColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconBack(onTap: _backPressed),
      ),
      body: WillPopScope(
        onWillPop: _onButtonBackPress,
        child: BlocListener<UploadBloc, UploadState>(
          cubit: uploadBloc,
          listener: _onStateChange,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                BlocBuilder<UploadBloc, UploadState>(
                  cubit: uploadBloc,
                  builder: (_, state) {
                    return state is UploadingState
                        ? XProgressIndicator(percen: state.percen)
                        : SizedBox();
                  },
                ),
                _buildCard(
                  container: this.design,
                  title: '#INTRODUCTION',
                ),
                Builder(
                  builder: (context) => Container(
                    margin: const EdgeInsets.only(right: 40, bottom: 30),
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: FloatingActionButton(
                        heroTag: 'edit',
                        tooltip: 'Edit',
                        child: SvgPicture.asset(
                          Assets.icEdit,
                          width: 30,
                          height: 30,
                          color: XedColors.white255,
                        ),
                        elevation: 0,
                        backgroundColor: XedColors.waterMelon,
                        onPressed: () => XError.f0(() => _openToolBox(context)),
                      ),
                    ),
                  ),
                ),
                buildDownloadingImage(isDownloadingImage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getBottomPadding() {
    try {
      if (_isEditText) {
        final hp10 = hp(10);
        final double bottom = _keyBoardShowing
            ? MediaQuery.of(context).viewInsets.bottom > hp10
                ? MediaQuery.of(context).viewInsets.bottom - hp10
                : hp10
            : hp(280);
        return bottom > 0 ? bottom : hp10;
      } else {
        return 0;
      }
    } catch (ex) {
      core.Log.error(ex);
      return 0;
    }
  }

  Widget _buildCard({
    @required core.Container container,
    @required String title,
  }) {
    final components = container?.components ?? const <core.Component>[];
    if (components.isEmpty) {
      return AddComponentIntroduction(title: title);
    } else {
      double marginHorizontal = 20;
      double marginTop = hp(25);
      double width = wp(355);
      double height = hp(504);
      double width27 = wp(125);
      double partPaddingTop = marginTop / 2;

      var margin = EdgeInsets.only(
        left: marginHorizontal,
        top: marginTop,
        right: marginHorizontal,
      );
      EdgeInsets margin2 = margin.copyWith(
        left: width27 - wp(5),
        top: margin.top / 2 - 1.2,
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
                color: XedColors.white,
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
                  _getBottomPadding() + hp(44),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController.getBackController(),
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisSize: MainAxisSize.max,
                    children: _buildListWidget(components),
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
              color: XedColors.white,
            ),
            child: Center(
              child: AutoSizeText(
                title ?? '',
                textAlign: TextAlign.justify,
                style: BoldTextStyle(12).copyWith(
                  letterSpacing: 0.43,
                  color: XedColors.brownGrey,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> _buildListWidget(List<core.Component> components) {
    int len = components.length;
    final widgets = <Widget>[];
    for (var i = 0; i < len; ++i) {
      widgets.add(_buildWidget(i, components[i]));
    }

    return widgets;
  }

  Widget _buildMoreButton(int index) {
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
        timer = _getTimer(index);
        _onComponentPressed(index, detail.globalPosition);
      }),
      onTapCancel: () => XError.f0(() {
        timer.cancel();
      }),
      onTap: () => XError.f0(() {
        timer.cancel();
      }),
    );
  }

  Widget _buildComponentSettingButton(int index) {
    return _isEditMode ? _buildMoreButton(index) : SizedBox();
  }

  Widget _buildWidget(
    int index,
    core.Component component,
  ) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        _componentWidget(
          index,
          component,
        ),
        _buildComponentSettingButton(index),
      ],
    );
  }

  void _onComponentPressed(int index, Offset location) {
    core.PopUtils.popUntil(context, EditCardIntroScreen.name);
    floatButtons.show(context, index, location);
  }

  Widget _componentWidget(int index, core.Component component) {
    switch (component.runtimeType) {
      case core.Audio:
        return XAudioPlayerWidget(
          component,
          index,
          mode: XComponentMode.Editing,
          key: keys[index],
        );
      case core.Text:
        return XTextEditWidget(
          key: keys[index],
          componentData: component,
          onSubmitted: (editedComponent, mode) => XError.f0(() {
            try {
              this._isEditText =
                  mode != EditTextMode.Done || FocusScope.of(context).hasFocus;
            } catch (ex) {
              core.Log.error(ex);
              this._isEditText = false;
            }
            _updateOrRemoveComponent(index, editedComponent);
          }),
          onTap: () => XError.f0(_onEditText),
          preScreenName: EditCardIntroScreen.name,
          onKeyboardShowing: _onKeyBoardShowing,
          bloc: focusBloc,
        );
      case core.Image:
        return XImageEditComponent(
          key: keys[index],
          componentData: component,
          onEditCompleted: (editedComponent) {
            _updateOrRemoveComponent(index, editedComponent);
          },
          onTap: () => XError.f0(_onOpenEditImage),
          preScreenName: EditCardIntroScreen.name,
          cubit: focusBloc,
        );
      case core.Video:
        return XVideoPlayerWidget(
          component,
          index,
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

  void _updateOrRemoveComponent(int index, core.Component component) {
    if (component == null) {
      this.design.deleteComponent(index);
    } else {
      this.design.updateComponent(index, component);
    }
    if (component is core.Image) this.onEditImageShowing = false;
    Future.delayed((Duration(milliseconds: 120))).then((_) {
      setState(() {});
    });
  }

  void _backPressed() {
    bloc.add(InfoChanged(design: this.design));
    core.PopUtils.popUntil(context, EditCardIntroScreen.name);
    Navigator.pop(context);
  }

  Future<bool> _onButtonBackPress() async {
    bloc.add(InfoChanged(design: this.design));
    return true;
  }

  void _openToolBox(BuildContext context) {
    floatButtons?.closeButton();
    closeUntil(EditCardIntroScreen.name);

    setState(
      () {
        _isEditMode = true;
        showBottomSheet(
          context: context,
          builder: (context) {
            return XToolboxWidget(
              title: 'ADD/EDIT',
              configs: introToolboxItems,
              callback: _onToolboxItemSelected,
            );
          },
        ).closed.whenComplete(() {
          setState(() {
            _isEditMode = false;
          });
        });
      },
    );
  }

  void _controlDownloadingWidget(bool visible) {
    isDownloadingImage = visible;
    setState(() {});
  }

  void _onToolboxItemSelected(ToolboxItem selectedId) async {
    floatButtons?.closeButton();
    closeUntil(EditCardIntroScreen.name);

    core.Component component;
    switch (selectedId) {
      case ToolboxItem.TEXT:
        component = core.Text();

        _addComponent(component);
        break;

      case ToolboxItem.IMAGE:
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
          preScreenName: EditCardIntroScreen.name,
        ).show();
        break;

      case ToolboxItem.VIDEO:
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
          preScreenName: EditCardIntroScreen.name,
        ).show();
        break;
      case ToolboxItem.VOICE:
        await XChooseAudioPopup(
          context: context,
          onAudioDataSubmitted: (data) {
            uploadBloc.add(
              UploadAudioEvent(data),
            );
          },
          onError: (Exception value) {
            dispatchError();
          },
          onUrlSelected: _onUrlSelected,
          preScreenName: EditCardIntroScreen.name,
          onVocabularySelected: (String url, String text) {
            _addComponent(core.Audio(url: url, text: text));
          },
        ).show();
        break;
      default:
        break;
    }

    closeUntil(EditCardIntroScreen.name);
  }

  void _addComponent(core.Component component) {
    if (component != null) {
      setState(() {
        this.design.addComponent(component);
        this.keys.add(UniqueKey());
      });
      this._scrollController.moveToBottom(false, 0);
    }
  }

  void swapKey(int fromIndex, int toIndex) {
    Key tmp = keys[fromIndex];
    keys[fromIndex] = keys[toIndex];
    keys[toIndex] = tmp;
  }

  void dispatchUploadImage({File file}) {
    uploadBloc.add(
      UploadImageEvent(file),
    );
  }

  void dispatchError() {
    uploadBloc.add(ErrorEvent());
  }

  @override
  void onFloatingClose() {}

  @override
  void onFloatingDelete() {
    setState(() {
      this.design.deleteComponent(_selectedIndex);
      keys.removeAt(_selectedIndex);
    });
  }

  @override
  void onFloatingEdit() {
    floatButtons?.closeButton();
    core.Component component = design.components[_selectedIndex];

    editComponent(component, _selectedIndex);
  }

  void editComponent(core.Component component, int selectedIndex) async {
    switch (component.runtimeType) {
      case core.Audio:
        core.Audio newComponent = await navigateToScreen(
          screen: AudioEditingScreen.edit(
            model: component,
            audioType: AudioType.Url,
          ),
          name: AudioEditingScreen.name,
        ) as core.Audio;
        if (newComponent != null)
          design.components[_selectedIndex] = newComponent;
        break;
      case core.Text:
        try {
          final key = keys[selectedIndex];
          focusBloc.add(RequestionFocusTextEvent(key));
        } catch (ex) {
          core.Log.error(ex);
        }
        break;
      default:
        break;
    }
  }

  @override
  void onFloatingMoveDown() {
    this.design.moveComponent(_selectedIndex, _selectedIndex + 1);

    int newIndex = min<int>(
      _selectedIndex + 1,
      this.design.getComponentCount(),
    );
    if (newIndex != _selectedIndex) {
      swapKey(_selectedIndex, newIndex);
    }
    _selectedIndex = newIndex;
    setState(() {});
  }

  @override
  void onFloatingMoveUp() {
    this.design.moveComponent(_selectedIndex, _selectedIndex - 1);
    int newIndex = max<int>(_selectedIndex - 1, 0);
    if (newIndex != _selectedIndex) {
      swapKey(_selectedIndex, newIndex);
    }
    _selectedIndex = newIndex;
    setState(() {});
  }

  @override
  void onFloatingOpen(int index) {
    _selectedIndex = index;
  }

  void _onStateChange(BuildContext context, UploadState state) {
    switch (state.runtimeType) {
      case UploadFailed:
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

  void _onOpenEditImage() {
    this.onEditImageShowing = true;
  }

  void _onEditText() {
    this._isEditText = true;
    if (onEditImageShowing)
      core.PopUtils.popUntil(context, EditCardIntroScreen.name);
    onEditImageShowing = false;
  }

  void _onKeyBoardShowing(bool value) {
    this._keyBoardShowing = value;
    this._isEditText = true;
    setState(() {});
  }

  Timer _getTimer(int index) {
    return Timer(const Duration(milliseconds: 250), () {
      _onComponentPressed(index, recentTapDownOffset);
    });
  }

  void _onUrlSeleted(String url) {
    if (core.VideoUtils.isYoutubeUrl(url)) {
      core.Component component = core.Video()..url = url;
      _addComponent(component);
    } else {
      dispatchError();
    }
  }

  void _onUrlSelected(String url) {
    if (core.UrlUtils.isFormatHtml(url)) {
      uploadBloc.add(UploadAudioUrlEvent(url));
    } else {
      dispatchError();
    }
  }

  void _showAudioEditing(AudioUrlUploadedSuccess state) async {
    AudioData audioData = await navigateToScreen<AudioData>(
      screen: AudioEditingScreen.inputUrl(
        url: state.url,
        showInputTextField: true,
        showIconRemove: false,
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
