import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/xerror.dart';

class EditTextMenuView extends StatelessWidget {
  final OnEditTextMenuCallback callback;

  EditTextMenuView(this.callback);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: XedColors.bottomSheetBackground,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: hp(20),
        ),
        child: Row(
          children: <Widget>[
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: hp(7)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                        child: Image.asset(
                      Assets.icEditGray,
                      color: Colors.white,
                      fit: BoxFit.fill,
                      width: hp(30),
                      height: hp(30),
                    )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hp(5)),
                      child: Text(
                        "EDIT TEXT",
                        style: RegularTextStyle(14).copyWith(
                            fontWeight: FontWeight.w100, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () => XError.f0(() {
                callback?.onShowToolbox();
              }),
            ),
            Expanded(child: Container()),
            IconButton(
              icon: Icon(
                Icons.check,
                size: hp(25),
                color: Colors.white,
              ),
              onPressed: () => XError.f0(() {
                callback?.onFinish();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class OnEditTextMenuCallback {
  void onShowToolbox();

  void onFinish();
}
