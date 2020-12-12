import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_sheets.dart';

class XDeckCategoryBottomSheet extends StatefulWidget {
  final String originalCategoryId;

  XDeckCategoryBottomSheet(this.originalCategoryId);

  @override
  _XDeckCategoryBottomSheetState createState() =>
      _XDeckCategoryBottomSheetState();
}

class _XDeckCategoryBottomSheetState extends State<XDeckCategoryBottomSheet> {
  String currentCategoryId;

  @override
  void initState() {
    super.initState();
    currentCategoryId = widget.originalCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return XedSheets.bottomSheet(
      context,
      'Select Category',
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioListTile<String>(
              groupValue: currentCategoryId ?? null,
              value: '',
              onChanged: (value) => XError.f0(() {
                setState(() {
                  currentCategoryId = '';
                });
                _onSelected();
              }),
              title: Text(
                'None',
                style: SemiBoldTextStyle(16).copyWith(
                  height: 1.4,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.black,
            ),
            RadioListTile<String>(
              groupValue: currentCategoryId ?? null,
              value: 'deck_cat_vocabulary',
              onChanged: (value) => XError.f0(() {
                setState(() {
                  currentCategoryId = 'deck_cat_vocabulary';
                });
                _onSelected();
              }),
              title: Text(
                'Vocabulary',
                style: SemiBoldTextStyle(16).copyWith(
                  height: 1.4,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.black,
            ),
            RadioListTile<String>(
              groupValue: currentCategoryId ?? null,
              value: 'deck_cat_grammar',
              onChanged: (value) => XError.f0(() {
                setState(() {
                  currentCategoryId = 'deck_cat_grammar';
                });
                _onSelected();
              }),
              title: Text(
                'Grammar',
                style: SemiBoldTextStyle(16).copyWith(
                  height: 1.4,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.black,
            ),
            RadioListTile<String>(
              groupValue: currentCategoryId ?? null,
              value: 'deck_cat_listening',
              onChanged: (value) => XError.f0(() {
                setState(() {
                  currentCategoryId = 'deck_cat_listening';
                });
                _onSelected();
              }),
              title: Text(
                'Listening',
                style: SemiBoldTextStyle(16).copyWith(
                  height: 1.4,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.black,
            ),
          ],
        ),
      ),
      result: currentCategoryId,
    );
  }

  void _onSelected() {
    Navigator.of(context).pop(currentCategoryId);
  }
}
