import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/x_toolbox_edit_text_widget.dart';
import 'package:the_flashcard/deck_creation/multi_choice/multi_choice.dart';
import 'package:the_flashcard/deck_creation/requestion_focus_bloc.dart';

enum EditTextMode { Done, EditText, TypingText }

class XTextEditWidget extends StatefulWidget {
  final core.Text componentData;
  final void Function(core.Text, EditTextMode) onSubmitted;
  final VoidCallback onTap;
  final String preScreenName;
  final ValueChanged<bool> onKeyboardShowing;
  final RequestionFocusBloc bloc;

  XTextEditWidget({
    Key key,
    @required this.componentData,
    @required this.onSubmitted,
    @required this.onTap,
    @required this.preScreenName,
    @required this.onKeyboardShowing,
    @required this.bloc,
  }) : super(key: key);

  @override
  _XTextEditWidgetState createState() => _XTextEditWidgetState();
}

class _XTextEditWidgetState extends State<XTextEditWidget>
    implements OnTextToolBoxCallBack {
  core.TextConfig textConfig;
  bool _editing = false;
  Key key = UniqueKey();
  final _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    textConfig = widget.componentData?.textConfig ?? core.TextConfig();
    _controller.text = widget.componentData?.text ?? '';
    _focusNode.addListener(() {
      if (_focusNode.hasFocus)
        _onTapTextField();
      else
        this._editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RequestionFocusBloc, RequestionFocusState>(
      bloc: widget.bloc,
      listener: (context, RequestionFocusState state) {
        if (state is RequestionFocusText && state.key == widget.key) {
          // this._onTapTextField(context);
          _focusNode.requestFocus();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(right: wp(5), left: wp(5)),
        child: _buildTextField(),
      ),
    );
  }

  Widget _buildTextField() {
    return Builder(
      builder: (context) {
        return TextField(
          key: key,
          cursorColor: XedColors.waterMelon,
          focusNode: _focusNode,
          controller: _controller,
          // onTap: () => XError.f1<BuildContext>(_onTapTextField, context),
          minLines: 1,
          maxLines: null,
          onChanged: (text) => XError.f0(() {
            widget.componentData.text = text;
          }),
          onSubmitted: (text) => XError.f0(() {
            setState(() {
              _onTextSubmitted(EditTextMode.Done);
            });
          }),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText:
                _editing ? '' : core.Config.getString("msg_tap_add_content"),
            focusColor: Colors.transparent,
            fillColor: XedColors.transparent,
            filled: true,
          ),
          style: textConfig.toTextStyle(),
          textAlign: textConfig.toTextAlign(),
        );
      },
    );
  }

  void _openTextCreationToolboxView(FocusNode focusNode) {
    Scaffold.of(this.context)
        .showBottomSheet(
          (context) => XToolboxEditTextWidget(
            focusNode: _focusNode,
            callback: this,
            defaultConfig: textConfig,
            disposeCallApplyChanged: false,
          ),
        )
        .closed
        .then(
      (_) {
        _unfocusTextField();
        _onTextSubmitted(EditTextMode.Done);
      },
    );
  }

  void _onTapTextField() {
    try {
      if (this.widget.onTap != null) this.widget.onTap();

      setState(() {
        _editing = true;
      });
      _openTextCreationToolboxView(_focusNode);
    } catch (ex) {
      core.Log.error(ex);
    }
  }

  void _unfocusTextField() {
    _focusNode.unfocus();
    try {
      if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
    } catch (ex) {}
  }

  void _closeTextCreationToolboxView() {
    if (Navigator.canPop(context)) {
      core.PopUtils.popUntil(context, widget.preScreenName);
    }
  }

  void _onTextSubmitted(EditTextMode mode) {
    if (widget.onSubmitted != null)
      widget.onSubmitted(
        widget.componentData,
        mode,
      );
  }

  @override
  void onConfigApply(core.TextConfig config, bool isCancel) {
    this.widget.componentData.textConfig = config;
    this.textConfig = config;

    if (!isCancel) {
      _unfocusTextField();
      _closeTextCreationToolboxView();
    }

    if (!_focusNode.hasFocus) {
      _onTextSubmitted(EditTextMode.Done);
    }
  }

  @override
  void onConfigChanged(core.TextConfig config,
      {bool textAlignChanged = false}) {
    setState(() {
      if (textAlignChanged) {
        key = UniqueKey();
      }
      this.textConfig = config;

      this.widget.componentData.textConfig = config;
    });
  }

  @override
  void onShowKeyboard(core.TextConfig config, bool showKeyboard) {
    setState(() {
      _editing = showKeyboard;
    });

    this._onTextSubmitted(
      showKeyboard ? EditTextMode.TypingText : EditTextMode.EditText,
    );

    if (widget.onKeyboardShowing != null)
      widget.onKeyboardShowing(showKeyboard);
  }

  @override
  void onTapAddBlank() {}
}
