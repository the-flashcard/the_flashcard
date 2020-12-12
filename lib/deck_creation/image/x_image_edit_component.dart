import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/deck_creation/edit_card_screen.dart';
import 'package:the_flashcard/deck_creation/edit_controller.dart';
import 'package:the_flashcard/deck_creation/image/x_toolbox_edit_image_component.dart';
import 'package:the_flashcard/deck_creation/requestion_focus_bloc.dart';
import 'package:the_flashcard/deck_creation/text_creation/x_text_edit_widget.dart';

class XImageEditComponent extends StatefulWidget {
  final void Function(core.Image) onEditCompleted;
  final core.Image componentData;
  final VoidCallback onTap;
  final XComponentEditController editController;
  final bool editing;
  final String preScreenName;
  final RequestionFocusBloc cubit;

  XImageEditComponent({
    Key key,
    @required this.onEditCompleted,
    @required this.componentData,
    @required this.onTap,
    this.editController,
    this.preScreenName = EditCardScreen.name,
    this.editing = false,
    @required this.cubit,
  }) : super(key: key);

  _XImageEditComponentState createState() =>
      _XImageEditComponentState(componentData);
}

class _XImageEditComponentState extends State<XImageEditComponent>
    implements OnImageEditToolBoxCallback {
  final core.Image _componentData;
  core.ImageConfig config;
  bool editing;
  bool showTextInput = false;

  _XImageEditComponentState(this._componentData) {
    this.config = core.ImageConfig.from(_componentData.imageConfig);
  }

  @override
  void initState() {
    super.initState();
    this.editing = widget.editing;
    showTextInput = this._componentData?.text != null ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.editController != null)
    //   widget.editController.addListeners(onEdit: _openToolbox);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        child: Container(
          height: hp(config.height ?? core.ImageConfig.DEF_HEIGHT),
          // height: hp(240),
          width: double.infinity,
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: XedColors.duckEggBlue,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            border: editing
                ? Border.all(color: Colors.pink[300], width: 2.0)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Center(
                  child: _componentData.url != null
                      ? Image.network(
                          _componentData.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height:
                              hp(config.height ?? core.ImageConfig.DEF_HEIGHT),
                        )
                      : SizedBox(),
                ),
                showTextInput ? _buildTextComponent() : SizedBox(),
              ],
            ),
          ),
        ),
        onTap: () => XError.f0(_openToolBox),
      ),
    );
  }

  Widget _buildTextComponent() {
    return XTextEditWidget(
      componentData: _componentData?.getTextComponent() ?? core.Text(),
      bloc: this.widget.cubit,
      onSubmitted: (editedComponent, mode) => XError.f0(() {
        this._componentData.text = editedComponent.text;
        this._componentData.textConfig = editedComponent.textConfig;

        if (mode == EditTextMode.Done && widget.componentData != null) {
          widget.onEditCompleted(core.Image.fromConfig(_componentData, config));
        }
      }),
      preScreenName: this.widget.preScreenName,
      onKeyboardShowing: (bool value) {},
      onTap: () {},
    );
  }

  void _openToolBox() {
    _closeAllPopUp();
    if (this.widget.onTap != null) this.widget.onTap();
    if (!editing) {
      setState(() {
        editing = true;
      });
      Scaffold.of(context).showBottomSheet(
        (context) => XToolboxEditImageComponent(
          defaultConfig: _componentData.imageConfig,
          callback: this,
          mode: showTextInput
              ? XToolboxEditImageMode.RemoveText
              : XToolboxEditImageMode.AddText,
        ),
      );
    } else
      _closeToolBox();
  }

  void _closeToolBox() {
    _closeAllPopUp();
    if (this.mounted)
      setState(() {
        editing = false;
      });
  }

  void _closeAllPopUp() {
    try {
      if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
    } catch (ex) {
      core.Log.error(ex);
    }
    core.PopUtils.popUntil(context, widget.preScreenName);
  }

  @override
  void onCancel(core.ImageConfig config) {
    onChanged(config);
    _closeToolBox();
  }

  @override
  void onChanged(core.ImageConfig config) {
    setState(() {
      this.config.height = config.height;
    });
  }

  @override
  void onDone(core.ImageConfig config) {
    onChanged(config);
    _closeToolBox();
    widget.onEditCompleted(core.Image.fromConfig(_componentData, config));
  }

  @override
  void onIconHeightPress(bool isOn) {}

  @override
  void onAddTextPressed() {
    _closeToolBox();
    _addTextbox();
  }

  @override
  void onRemoveTextPressed() {
    _closeToolBox();
    _removeTextbox();
  }

  void _removeTextbox() {
    this._componentData.text = null;
    this.showTextInput = false;
    widget.onEditCompleted(core.Image.fromConfig(_componentData, config));
    if (mounted) setState(() {});
  }

  void _addTextbox() {
    this._componentData.text = '';
    _componentData.textConfig = core.TextConfig()
      ..color = Color.fromARGB(255, 255, 255, 255).value
      ..background = Color(0xffae2a2a).value
      ..fontWeight = FontWeight.bold.index
      ..fontSize = 18;
    this.showTextInput = true;
    widget.onEditCompleted(core.Image.fromConfig(_componentData, config));
    if (mounted) setState(() {});
  }
}
