import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class XBottomSheetTextFieldWidget extends StatefulWidget {
  final String title;
  final String text;
  final String hintText;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;
  final TextInputAction textInputAction;
  final String valueKey;

  const XBottomSheetTextFieldWidget({
    Key key,
    this.title = '',
    this.text = '',
    this.onSubmit,
    this.onCancel,
    this.hintText = '',
    @required this.textInputAction,
    this.valueKey = '',
  }) : super(key: key);

  @override
  _XBottomSheetTextFieldWidgetState createState() =>
      _XBottomSheetTextFieldWidgetState();
}

class _XBottomSheetTextFieldWidgetState
    extends State<XBottomSheetTextFieldWidget> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController()..text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double height70 = screen.height * 0.7;
    return Container(
      height: height70,
      decoration: BoxDecoration(
        color: XedColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Flexible(
            child: Container(
              color: XedColors.transparent,
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    child: Text(
                      'Cancel',
                      style: RegularTextStyle(12).copyWith(
                        color: XedColors.waterMelon,
                      ),
                    ),
                    onPressed: () => XError.f0(() {
                      Navigator.of(context).pop();
                      if (widget.onCancel != null) widget.onCancel();
                    }),
                  ),
                  Flexible(
                    child: Material(
                      color: XedColors.transparent,
                      child: Text(
                        widget.title,
                        style: BoldTextStyle(14).copyWith(
                          color: XedColors.blackTextColor,
                          height: 1.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  RawMaterialButton(
                    child: Text(
                      'Done',
                      style: RegularTextStyle(12).copyWith(
                        color: XedColors.blackTextColor,
                      ),
                    ),
                    onPressed: () => XError.f0(() {
                      Navigator.of(context).pop();
                      if (widget.onSubmit != null)
                        widget.onSubmit(controller.text);
                    }),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 8,
            child: Material(
              // color: XedColors.white,
              child: Scaffold(
                body: TextField(
                  expands: true,
                  autofocus: true,
                  autocorrect: false,
                  textInputAction: widget.textInputAction,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    fillColor: XedColors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  controller: controller,
                  maxLines: null,
                  key: Key(widget?.valueKey ?? ''),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
