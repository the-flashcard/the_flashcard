import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';

class BottomEditPanel extends StatefulWidget {
  final TextEditingController controller;
  final bool haveBlank;
  final VoidCallback onTapCheck;
  final VoidCallback onTapEdit;
  static int numberOfFIB = 0;

  BottomEditPanel({
    @required this.controller,
    @required this.onTapCheck,
    this.haveBlank = false,
    this.onTapEdit,
  });

  @override
  _BottomEditPanelState createState() => _BottomEditPanelState();
}

class _BottomEditPanelState extends State<BottomEditPanel> {
  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      FlatButton.icon(
          onPressed: () => XError.f0(() {
                if (widget.onTapEdit != null) {
                  widget.onTapEdit();
                } else {
                  setState(() {
                    widget.controller.selection = TextSelection.collapsed(
                      offset: widget.controller.text.length,
                    );
                  });
                }
              }),
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          label: Text(
            "EDIT TEXT",
            style: TextStyle(color: Colors.white, letterSpacing: 0.5),
          )),
      widget.haveBlank
          ? FlatButton.icon(
              onPressed: () => XError.f0(() => _addBlank(widget.controller)),
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              label: Text(
                "BLANK",
                style: TextStyle(color: Colors.white, letterSpacing: 0.5),
              ),
            )
          : Container(),
      Spacer(),
      FlatButton(
        child: Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () => XError.f0(widget.onTapCheck),
      )
    ]);
  }

  void _addBlank(TextEditingController controller) {
    int pos = controller.selection.start;
    String textAfterAdd = controller.text.substring(0, pos) +
        core.FIBUtils.createBlank(0) +
        controller.text.substring(pos);
    textAfterAdd = core.FIBUtils.format(textAfterAdd);
    controller.value = controller.value.copyWith(text: textAfterAdd);
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
  }
}
