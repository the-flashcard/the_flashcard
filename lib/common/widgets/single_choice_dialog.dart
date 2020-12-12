import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class SingleChoiceDialog extends StatefulWidget {
  final List<String> options;
  final ValueChanged<int> onPressed;
  final String decisionContent;
  final String title;

  SingleChoiceDialog(
      {@required this.title,
      @required this.options,
      @required this.onPressed,
      @required this.decisionContent})
      : assert(title != null),
        assert(options != null),
        assert(onPressed != null),
        assert(decisionContent != null);

  @override
  _SingleChoiceDialogState createState() => _SingleChoiceDialogState();
}

class _SingleChoiceDialogState extends State<SingleChoiceDialog> {
  int _groupValue = 1;

  // String _selectedText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
          padding: EdgeInsets.only(
              top: hp(10), left: wp(20), right: wp(20), bottom: hp(20)),
          width: double.infinity,
          color: XedColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: BoldTextStyle(32),
              ),
              _optionListView(),
              DecisionButton(
                content: widget.decisionContent,
                onPressed: () => XError.f0(() {
                  widget.onPressed(_groupValue);
                  //dismiss
                  Navigator.popUntil(
                      context, (Route<dynamic> route) => route is PageRoute);
                }),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _optionListView() {
    return ListView.builder(
      padding: EdgeInsets.only(top: hp(20), bottom: 0, left: 0, right: 0),
      shrinkWrap: true,
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        return _optionWidget(index);
      },
    );
  }

  Widget _optionWidget(int value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      child: RadioListTile(
        title: Text(
          widget.options[value],
          style: SemiBoldTextStyle(14),
        ),
        groupValue: _groupValue,
        value: value,
        onChanged: (val) {
          setState(() {
            _groupValue = value;
            // _selectedText = widget.options[value];
          });
        },
      ),
    );
  }
}
