import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/resources.dart';
import 'package:the_flashcard/common/resources/xed_colors.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/xerror.dart';

enum EditMode { HINT, KEY_BOARD }

abstract class OnAnswerTextCallBack {
  void onSelectedElement(String element);

  void onPressRefresh();

  void onPressDelete();

  void onShowKeyboard(bool showKeyboard);

  void onSubmitted();
}

class XToolboxAnswerTextWidget extends StatefulWidget {
  final List<FocusNode> focusNodeList;
  final List<TextEditingController> controllerList;
  final OnAnswerTextCallBack callBack;
  final ValueNotifier<void> listenerHideEditPanel;
  final List<String> answerList;
  final int location;

  XToolboxAnswerTextWidget(
      {Key key,
      this.focusNodeList,
      this.controllerList,
      @required this.callBack,
      @required this.answerList,
      this.listenerHideEditPanel,
      this.location = 0})
      : super(key: key);

  @override
  _XToolboxAnswerTextWidgetState createState() =>
      _XToolboxAnswerTextWidgetState();
}

class _XToolboxAnswerTextWidgetState extends State<XToolboxAnswerTextWidget> {
  EditMode _editMode;
  List<List<Hint>> hintList = [];
  int indexAnswer;
  bool _showingHint = false;

  @override
  void initState() {
    super.initState();
    _editMode = EditMode.KEY_BOARD;
    hintList = _initHintList(widget.answerList);
    widget.listenerHideEditPanel?.addListener(_hideKeyboard);
  }

  @override
  void dispose() {
    this.widget.listenerHideEditPanel?.removeListener(_hideKeyboard);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.context = context;
    return Material(
      color: XedColors.bottomSheetBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildActionBarView(),
          _editMode == EditMode.HINT
              ? _buildHint(hintList[widget.location],
                  widget.controllerList[widget.location])
              : SizedBox(),
        ],
      ),
    );
  }

  /// Action menu items
  Widget _buildActionBarView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp(20), vertical: hp(7)),
      child: Row(
        children: <Widget>[
          _buildButtonEditMode(),
          IconButton(
            icon: SvgPicture.asset(
              Assets.icVoice,
              color: XedColors.white20,
            ),
            onPressed: () {},
          ),
          Spacer(),
          IconButton(
            key: Key(DriverKey.ICON_SUBMIT),
            icon: Icon(Icons.check, size: hp(25), color: XedColors.white),
            onPressed: () => XError.f0(() => widget?.callBack?.onSubmitted()),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonEditMode() {
    return _editMode == EditMode.HINT
        ? IconButton(
            icon: Icon(Icons.keyboard, size: hp(25), color: Colors.white),
            onPressed: _onTapKeyboardIcon,
          )
        : IconButton(
            icon: SvgPicture.asset(Assets.icTips),
            onPressed: _onTapHintIcon,
          );
  }

  Widget _buildHint(List<Hint> hintList, TextEditingController controller) {
    List<String> _characterText = controller.text.split("");
    indexAnswer = controller.text.length - 1;
    core.Log.debug(indexAnswer);
    _characterText.forEach((character) {
      int index = controller.text.indexOf(character);
      var hint = hintList.firstWhere((hint) => hint.element == character,
          orElse: () => null);
      if (hint != null && !_showingHint) {
        hint.choose(index);
      }
    });
    setState(() {
      _showingHint = true;
    });
    return Column(
      children: <Widget>[
        /// Divider
        Container(
          width: double.infinity,
          height: hp(1),
          color: XedColors.divider,
        ),
        SizedBox(
          height: hp(130),
          child: Column(
            children: <Widget>[
              _buildButtonDeleteRefresh(),
              _buildHintList(hintList),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildButtonDeleteRefresh() {
    return Padding(
      padding: EdgeInsets.only(top: hp(22), left: wp(20)),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: XedColors.white,
              size: 24.0,
            ),
            onPressed: _onTapRefresh,
          ),
          IconButton(
            icon: SvgPicture.asset(Assets.icDelCharWhite),
            onPressed: _onTapDeleteChar,
          ),
        ],
      ),
    );
  }

  Widget _buildHintList(List<Hint> hintList) {
    final widgetElement = <Widget>[];
    for (int i = 0; i < hintList.length; i++) {
      widgetElement.add(_hintBoxWidget(hintList[i]));
      if (i != hintList.length - 1)
        widgetElement.add(SizedBox(
          width: wp(10),
        ));
    }
    return Padding(
      padding: EdgeInsets.only(bottom: hp(10)),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: wp(25)),
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgetElement,
        ),
      ),
    );
  }

  Widget _hintBoxWidget(Hint hint) {
    bool active = true;
    if (hint.indexInAnswer != -1) {
      active = false;
    }
    return InkWell(
      onTap: active ? () => XError.f1<Hint>(_onTapHintBox, hint) : null,
      child: Container(
        height: hp(36),
        width: hp(36),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
            color: XedColors.white14),
        child: Center(
          child: Text(
            hint.element,
            style: active
                ? SemiBoldTextStyle(20)
                    .copyWith(color: XedColors.whiteTextColor)
                : SemiBoldTextStyle(20)
                    .copyWith(color: XedColors.battleShipGrey),
          ),
        ),
      ),
    );
  }

  List<List<Hint>> _initHintList(List<String> answerList) {
    List<List<Hint>> result = [];
    for (var i = 0; i < answerList.length; i++) {
      List<String> answerElement = answerList[i].split("")..shuffle();
      List<Hint> hintList = [];
      List.generate(answerElement.length,
          (int index) => hintList.add(Hint(answerElement[index])));
      result.add(hintList);
    }
    return result;
  }

  void _hideKeyboard() {
    setState(() {
      _editMode = EditMode.KEY_BOARD;
    });
  }

  void _refreshHintList() {
    hintList[widget.location].forEach((hint) => hint.refresh());
  }

  void _onTapKeyboardIcon() {
    XError.f0(() {
      if (widget.focusNodeList != null) {
        setState(() {
          _editMode = EditMode.KEY_BOARD;
          FocusScope.of(context)
              .requestFocus(widget.focusNodeList[widget.location]);
          _refreshHintList();
          _showingHint = false;
        });
      }
      widget?.callBack?.onShowKeyboard(true);
    });
  }

  void _onTapHintIcon() {
    XError.f0(() {
      FocusScope.of(context).unfocus();
      setState(() {
        _editMode = EditMode.HINT;
      });
      widget?.callBack?.onShowKeyboard(false);
    });
  }

  void _onTapHintBox(Hint hint) {
    widget?.callBack?.onSelectedElement(hint.element);
    setState(() {
      indexAnswer++;
      hint.indexInAnswer = indexAnswer;
    });
  }

  void _onTapDeleteChar() {
    XError.f0(() {
      widget?.callBack?.onPressDelete();
      indexAnswer = widget.controllerList[widget.location].text.length;
      var hintToActive = hintList[widget.location]
          .firstWhere((hint) => hint.indexInAnswer == indexAnswer);
      if (hintToActive != null) {
        hintToActive..indexInAnswer = -1;
      }
      setState(() {});
    });
  }

  void _onTapRefresh() {
    XError.f0(() {
      setState(() {
        _refreshHintList();
        widget?.callBack?.onPressRefresh();
      });
    });
  }
}

class Hint {
  String element;
  int indexInAnswer;

  Hint(this.element, {this.indexInAnswer = -1});

  void refresh() {
    indexInAnswer = -1;
  }

  void choose(int index) {
    indexInAnswer = index;
  }
}
