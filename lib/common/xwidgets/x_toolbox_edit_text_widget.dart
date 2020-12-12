import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/palette_color.dart';
import 'package:the_flashcard/environment/driver_key.dart';
import 'package:the_flashcard/xerror.dart';

class FontFamilyEntity {
  FontFamilyType type;
  String fontName;
  String fontFamily;

  FontFamilyEntity(this.type, this.fontName, this.fontFamily);
}

enum FontFamilyType { HARMONIA, GRACELAND, ROUNDED, TIEMPOS, GOTHIC, NONE }

class ParagraphFunctionEntity {
  TextFunctionType type;
  String icon;
  bool isSvg;

  ParagraphFunctionEntity(this.type, this.icon, {this.isSvg = true});
}

enum TextFunctionType {
  TEXT_SIZE,
  TEXT_SPACE,
  LINE_HEIGHT,
  TEXT_COLOR,
  TEXT_BG_COLOR
}

enum CustomFontStyle { BOLD, ITALIC }

enum EditMode { EDIT_TEXT, KEY_BOARD }

abstract class OnTextToolBoxCallBack {
  void onConfigChanged(core.TextConfig config, {bool textAlignChanged = false});

  void onConfigApply(core.TextConfig config, bool isCancel);

  void onShowKeyboard(core.TextConfig config, bool showKeyboard);

  void onTapAddBlank();
}

class XToolboxEditTextWidget extends StatefulWidget {
  final OnTextToolBoxCallBack callback;
  final FocusNode focusNode;

  final core.TextConfig defaultConfig;
  final core.TextConfig config;

  final bool autoFocus;
  final bool disposeCallApplyChanged;

  //Change
  final ValueNotifier<void> listenerHideEditPanel;
  final bool hasBlankComponent;

  XToolboxEditTextWidget(
      {Key key,
      this.callback,
      this.focusNode,
      this.defaultConfig,
      this.autoFocus = true,
      this.listenerHideEditPanel,
      this.hasBlankComponent = false,
      this.disposeCallApplyChanged = true})
      : this.config = core.TextConfig.from(defaultConfig),
        super(key: key);

  @override
  _XToolboxEditTextWidgetState createState() => _XToolboxEditTextWidgetState();
}

class _XToolboxEditTextWidgetState extends State<XToolboxEditTextWidget> {
  /// Font family view data set
  final _fontFamilyData = <FontFamilyEntity>[
    FontFamilyEntity(
      FontFamilyType.HARMONIA,
      "Harmonia",
      FontFamily.harmoniaSansProCyr,
    ),
    FontFamilyEntity(
      FontFamilyType.GRACELAND,
      "Graceland",
      FontFamily.graceland,
    ),
    FontFamilyEntity(
      FontFamilyType.ROUNDED,
      "Rounded",
      FontFamily.round,
    ),
    FontFamilyEntity(
      FontFamilyType.TIEMPOS,
      "Tiempos",
      FontFamily.tiempos,
    ),
    FontFamilyEntity(
      FontFamilyType.GOTHIC,
      "Gothic",
      FontFamily.gothic,
    ),
  ];
  final _paragraphData = <ParagraphFunctionEntity>[
    ParagraphFunctionEntity(
      TextFunctionType.TEXT_SIZE,
      Assets.icAA,
    ),
    ParagraphFunctionEntity(
      TextFunctionType.TEXT_SPACE,
      Assets.icSpaceWhite,
    ),
    ParagraphFunctionEntity(
      TextFunctionType.LINE_HEIGHT,
      Assets.icSpaceWhiteCopy,
    ),
    ParagraphFunctionEntity(
      TextFunctionType.TEXT_COLOR,
      Assets.icInvertColorsMaterial,
    ),
    ParagraphFunctionEntity(
      TextFunctionType.TEXT_BG_COLOR,
      Assets.icBgColor,
    ),
  ];
  final _maxFontSize = 50.0;
  final _maxLetterSpacing = 20.0;
  final _fontFamilyItemExtent = 100.0;
  final _maxWordSpacing = 20.0;

  /// Text colors palette

  FontFamilyEntity _selectedFontFamily;
  ScrollController _fontFamilyScrollController;
  core.TextConfig config;
  double _defaultNoneItemWidth = 0.0;
  int _stackIndex = 0;
  bool isApply = false;

  /// Paragraph view data set
  ParagraphFunctionEntity _selectedParagraphStyle;
  EditMode _editMode = EditMode.KEY_BOARD;
  int index = -1;
  bool submit = false;

  @override
  void initState() {
    super.initState();
    this.config = widget.config;

    _selectedFontFamily = _fontFamilyData.firstWhere(
      (data) {
        ++index;
        return config.fontFamily == data.fontFamily;
      },
      orElse: () {
        index = 0;
        return _fontFamilyData[0];
      },
    );

    _fontFamilyScrollController = ScrollController();

    _selectedParagraphStyle = _paragraphData[0];

    widget.listenerHideEditPanel?.addListener(_hideKeyboard);

    if (widget.autoFocus)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.focusNode != null) {
          FocusScope.of(context).requestFocus(widget.focusNode);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    _defaultNoneItemWidth = MediaQuery.of(context).size.width * .35;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        color: XedColors.bottomSheetBackground,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              /// Action menu items
              _buildActionBarView(),
              _editMode == EditMode.EDIT_TEXT ? _buildEditText() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditText() {
    if (!submit)
      Future.delayed(const Duration(milliseconds: 150)).then((_) {
        if (mounted) _processJumpToPosition(index);
        submit = true;
      });
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        /// Divider
        Container(
          width: double.infinity,
          height: hp(1),
          color: XedColors.divider,
        ),

        /// Select font family
        _buildSelectFontFamilyView(context),

        /// Select font style
        _buildSelectTextStyleView(),

        /// Select paragraph style
        _buildSelectParagraphStyleView(),

        /// Paragraph function view
        _buildParagraphFunctionView()
      ],
    );
  }

  /// Action menu items
  Widget _buildActionBarView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp(20), vertical: 5),
      child: Row(
        children: <Widget>[
          _buildLeftMenuActionBar(),
          Expanded(child: Container()),
          IconButton(
            key: Key(DriverKey.ICON_SUBMIT),
            icon: Icon(Icons.check, size: hp(25), color: Colors.white),
            onPressed: () => XError.f0(() {
              isApply = true;
              widget.callback?.onConfigApply(config, false);
            }),
          )
        ],
      ),
    );
  }

  Widget _buildLeftMenuActionBar() {
    return Row(
      children: <Widget>[
        _editMode == EditMode.EDIT_TEXT
            ? IconButton(
                icon: Icon(Icons.keyboard, size: hp(25), color: Colors.white),
                onPressed: () => XError.f0(() {
                  if (widget.focusNode != null) {
                    setState(() {
                      _editMode = EditMode.KEY_BOARD;
                      if (widget.autoFocus)
                        FocusScope.of(context).requestFocus(widget.focusNode);
                    });
                  }

                  widget.callback?.onShowKeyboard(config, true);
                }),
              )
            : InkWell(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: hp(3), right: hp(7), top: hp(7), bottom: hp(7)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.edit, size: hp(25), color: Colors.white),
                      Padding(padding: const EdgeInsets.only(right: 5)),
                      Text(
                        "EDIT TEXT",
                        style: RegularTextStyle(14)
                            .copyWith(color: XedColors.white),
                      )
                    ],
                  ),
                ),
                onTap: () => XError.f0(() {
                  if (widget.autoFocus) FocusScope.of(context).unfocus();
                  widget.callback?.onShowKeyboard(config, false);

                  Future.delayed(const Duration(milliseconds: 200)).then((_) {
                    setState(() {
                      submit = false;
                      _editMode = EditMode.EDIT_TEXT;
                    });
                  });
                }),
              ),
        widget.hasBlankComponent && _editMode == EditMode.KEY_BOARD
            ? _buildBlank()
            : SizedBox(),
      ],
    );
  }

  Widget _buildBlank() {
    return FlatButton.icon(
      key: Key(DriverKey.FIB_BLANK),
      onPressed: () => XError.f0(() => widget.callback.onTapAddBlank()),
      icon: Icon(
        Icons.edit,
        color: Colors.white,
      ),
      label: Text(
        "BLANK",
        style: TextStyle(color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }

  /// ----------------- REGION - BUILD SELECT FONT FAMILY VIEW -----------------

  Widget _buildSelectFontFamilyView(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(top: hp(10)),
      height: hp(65),
      child: ListView.builder(
        controller: _fontFamilyScrollController,
        shrinkWrap: true,
        itemCount: _fontFamilyData.length,
        scrollDirection: Axis.horizontal,
        itemExtent: _fontFamilyItemExtent,
        padding: EdgeInsets.only(
          left: (_screenWidth - _fontFamilyItemExtent) / 2,
          right: _defaultNoneItemWidth,
        ),
        itemBuilder: (_, int index) {
          var font = _fontFamilyData[index];
          return font.type != FontFamilyType.NONE
              ? InkWell(
                  child: _buildFontFamilyItemView(font),
                  onTap: () => XError.f0(() {
                    if (font.type != _selectedFontFamily.type) {
                      _processJumpToPosition(index);
                      setState(() {
                        _selectedFontFamily = font;
                      });
                      config.fontFamily = font.fontFamily;
                      widget.callback?.onConfigChanged(config);
                    }
                  }),
                )
              : Container(width: _defaultNoneItemWidth);
        },
      ),
    );
  }

  /// Still under develop, need improve more because hardcode item size
  void _processJumpToPosition(int index) {
    if (index < _fontFamilyData.length) {
      // _fontFamilyScrollController.
      _fontFamilyScrollController.animateTo(
        ((index - 1) * _fontFamilyItemExtent + _fontFamilyItemExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  /// Paragraph item view
  Widget _buildFontFamilyItemView(FontFamilyEntity item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: hp(9)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: _selectedFontFamily?.type == item.type ? 5 : 0,
            ),
            child: Text(
              item.fontName,
              maxLines: 1,
              style: RegularTextStyle(14).copyWith(
                fontFamily: item.fontFamily,
                color: _selectedFontFamily?.type == item.type
                    ? Colors.white
                    : XedColors.battleShipGrey,
                height: 1.4,
              ),
            ),
          ),
          _selectedFontFamily?.type == item.type
              ? Container(
                  margin: EdgeInsets.only(top: hp(6)),
                  // width: 100,
                  color: Colors.white,
                  height: hp(2),
                )
              : Container()
        ],
      ),
    );
  }

  /// ----------------- END REGION - BUILD SELECT FONT FAMILY VIEW -----------------

  /// ----------------- REGION - BUILD SELECT FONT STYLE VIEW -----------------

  Widget _buildSelectTextStyleView() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: wp(25), vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: wp(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(hp(10))),
        color: XedColors.divider,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                config.fontWeight = config.fontWeight == FontWeight.bold.index
                    ? FontWeight.normal.index
                    : FontWeight.bold.index;
              });
              widget.callback?.onConfigChanged(config);
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                child: Icon(
                  Icons.format_bold,
                  color: config.fontWeight == FontWeight.bold.index
                      ? XedColors.white
                      : XedColors.battleShipGrey,
                ),
                width: hp(24),
                height: hp(24),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                config.fontStyle = (config.fontStyle == FontStyle.italic.index
                    ? FontStyle.normal.index
                    : FontStyle.italic.index);
              });
              widget.callback?.onConfigChanged(config);
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                child: Icon(
                  Icons.format_italic,
                  color: config.fontStyle == FontStyle.italic.index
                      ? XedColors.white
                      : XedColors.battleShipGrey,
                ),
                width: hp(24),
                height: hp(24),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                config.isUnderline = !config.isUnderline;
                widget.callback?.onConfigChanged(config);
              });
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                child: Icon(
                  Icons.format_color_text,
                  color: config.isUnderline
                      ? XedColors.white
                      : XedColors.battleShipGrey,
                ),
                width: hp(24),
                height: hp(24),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            onTap: () => XError.f0(() {
              setState(() {
                config.textAlign = toTextAlign(config.textAlign).index;
                widget.callback?.onConfigChanged(
                  config,
                  textAlignChanged: true,
                );
              });
            }),
            child: Padding(
              padding: EdgeInsets.all(hp(10)),
              child: SizedBox(
                width: hp(24),
                height: hp(24),
                child: Icon(
                  toIcon(config.textAlign),
                  color: XedColors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  TextAlign toTextAlign(int index) {
    if (index == TextAlign.left.index) return TextAlign.center;
    if (index == TextAlign.center.index) return TextAlign.right;
    if (index == TextAlign.right.index) return TextAlign.left;
    return TextAlign.start;
  }

  IconData toIcon(int index) {
    if (index == TextAlign.left.index) return Icons.format_align_left;
    if (index == TextAlign.center.index) return Icons.format_align_center;
    if (index == TextAlign.right.index) return Icons.format_align_right;
    return Icons.format_align_left;
  }

  /// ----------------- END REGION - BUILD SELECT FONT STYLE VIEW -----------------

  /// ----------------- REGION - BUILD SELECT PARAGRAPH STYLE VIEW -----------------

  Widget _buildSelectParagraphStyleView() {
    List<Widget> _items = _paragraphData.map((item) {
      return InkWell(
        borderRadius: BorderRadius.all(Radius.circular(100)),
        onTap: () => XError.f0(() {
          if (item.type != _selectedParagraphStyle.type) {
            switch (item.type) {
              case TextFunctionType.TEXT_SIZE:
                _stackIndex = 0;
                break;
              case TextFunctionType.TEXT_SPACE:
                _stackIndex = 1;
                break;
              case TextFunctionType.LINE_HEIGHT:
                _stackIndex = 2;
                break;
              case TextFunctionType.TEXT_COLOR:
                _stackIndex = 3;
                break;
              case TextFunctionType.TEXT_BG_COLOR:
                _stackIndex = 4;
                break;
              default:
                break;
            }
            widget.callback?.onConfigChanged(config);
            setState(() {
              _selectedParagraphStyle = item;
            });
          }
        }),
        child: Padding(
          padding: EdgeInsets.all(hp(10)),
          child: SizedBox(
            child: item.isSvg
                ? SvgPicture.asset(
                    item.icon,
                    color: item.type == _selectedParagraphStyle.type
                        ? Colors.white
                        : XedColors.battleShipGrey,
                  )
                : Image.asset(
                    item.icon,
                    fit: BoxFit.fill,
                    color: item.type == _selectedParagraphStyle.type
                        ? Colors.white
                        : XedColors.battleShipGrey,
                  ),
            width: hp(24),
            height: hp(24),
          ),
        ),
      );
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: wp(25), vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: wp(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: XedColors.divider,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _items,
      ),
    );
  }

  Widget _buildParagraphFunctionView() {
    return Container(
      height: 50,
      color: XedColors.bottomSheetBackground,
      margin: EdgeInsets.only(top: hp(15), bottom: hp(25)),
      child: IndexedStack(
        index: _stackIndex,
        children: <Widget>[
          /// Font-size controller
          _buildFontSizeControllerWidget(),

          /// Letter Spacing controller
          _buildLetterSpacingControllerWidget(),

          /// Word spacing controller
          _buildWordSpacingControllerWidget(),

          /// Font-size controller
          _buildTextColorController(),

          /// Backgrouond text color
          _buildBackgroundTextColorController(),
        ],
      ),
    );
  }

  Widget _buildFontSizeControllerWidget() {
    return Container(
      padding: EdgeInsets.only(left: wp(40)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoSlider(
              value: config.fontSize,
              min: 0.0,
              max: _maxFontSize,
              onChanged: (double value) {
                XError.f0(() => {setState(() => config.fontSize = value)});
              },
              onChangeEnd: (double value) {
                XError.f0(() => widget.callback?.onConfigChanged(config));
              },
              activeColor: XedColors.roseRed,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(11)),
            child: Container(
              width: 35,
              child: Text(
                "${(config.fontSize * 100 ~/ _maxFontSize)}%",
                style: RegularTextStyle(10).copyWith(color: XedColors.roseRed),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLetterSpacingControllerWidget() {
    return Container(
      padding: EdgeInsets.only(left: wp(40)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoSlider(
              value: config.letterSpacing,
              min: 0.0,
              max: _maxLetterSpacing,
              onChanged: (double value) {
                XError.f0(() => setState(() => config.letterSpacing = value));
              },
              onChangeEnd: (double value) {
                XError.f0(() => widget.callback?.onConfigChanged(config));
              },
              activeColor: XedColors.roseRed,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(11)),
            child: Container(
              width: 35,
              child: Text(
                "${(config.letterSpacing * 100 ~/ _maxLetterSpacing)}%",
                style: RegularTextStyle(10).copyWith(color: XedColors.roseRed),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWordSpacingControllerWidget() {
    return Container(
      padding: EdgeInsets.only(left: wp(40)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CupertinoSlider(
              value: config.lineHeight,
              min: 0.0,
              max: _maxWordSpacing,
              onChanged: (double value) {
                XError.f0(() => setState(() => config.lineHeight = value));
              },
              onChangeEnd: (double value) {
                XError.f0(() => widget.callback?.onConfigChanged(config));
              },
              activeColor: XedColors.roseRed,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wp(11)),
            child: Container(
              width: 35,
              child: Text(
                "${(config.lineHeight * 100 ~/ _maxWordSpacing)}%",
                style: RegularTextStyle(10).copyWith(color: XedColors.roseRed),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextColorController() {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: () {
            return paletteColors.map(
              (item) {
                return InkWell(
                  onTap: () => XError.f0(() {
                    setState(() {
                      config.color = item.value;
                    });
                    widget.callback?.onConfigChanged(config);
                  }),
                  child: Container(
                    width: hp(53),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          item.value == config.color
                              ? Container(
                                  width: hp(29),
                                  height: hp(29),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: XedColors.white,
                                      width: hp(1),
                                    ),
                                  ),
                                )
                              : Container(),
                          Container(
                            width: hp(25),
                            height: hp(25),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: XedColors.white,
                                width:
                                    item.value == config.color ? hp(1) : hp(2),
                              ),
                              color: item,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ).toList();
          }(),
        ),
      ),
    );
  }

  Widget _buildBackgroundTextColorController() {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: () {
            return paletteColors.map((item) {
              return InkWell(
                onTap: () => XError.f0(() {
                  setState(() {
                    if (item.value == paletteColors.first.value)
                      config.background = XedColors.transparent.value;
                    else
                      config.background = item.value;
                  });
                  widget.callback?.onConfigChanged(config);
                }),
                child: Container(
                  width: hp(53),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        (item.value == config.background ||
                                (item.value == paletteColors.first.value &&
                                    config.background ==
                                        XedColors.transparent.value))
                            ? Container(
                                width: hp(29),
                                height: hp(29),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                  border: Border.all(
                                    color: XedColors.white,
                                    width: hp(1),
                                  ),
                                ),
                              )
                            : Container(),
                        Container(
                          width: hp(25),
                          height: hp(25),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            border: Border.all(
                              color: XedColors.white,
                              width: (item.value == config.background ||
                                      (item.value ==
                                              paletteColors.first.value &&
                                          config.background ==
                                              XedColors.transparent.value))
                                  ? hp(1)
                                  : hp(2),
                            ),
                            color: item,
                          ),
                        ),
                        item == paletteColors[0]
                            ? Container(
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: XedColors.white,
                                ),
                              )
                            : SizedBox()
                        // : Container(),
                      ],
                    ),
                  ),
                ),
              );
            }).toList();
          }(),
        ),
      ),
    );
  }

  /// ----------------- END REGION - BUILD SELECT PARAGRAPH STYLE VIEW -----------------
  @override
  void dispose() {
    this.widget.listenerHideEditPanel?.removeListener(_hideKeyboard);

    // if (!isApply) {
    if (widget.disposeCallApplyChanged)
      this.widget.callback?.onConfigApply(this.widget.defaultConfig, true);
    // }
    super.dispose();
  }

  void _hideKeyboard() {
    setState(() {
      _editMode = EditMode.KEY_BOARD;
    });
  }
}
