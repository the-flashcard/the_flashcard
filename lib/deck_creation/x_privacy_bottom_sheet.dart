import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';
import 'package:the_flashcard/common/resources/xed_sheets.dart';

class XDeckPrivacyBottomSheet extends StatefulWidget {
  final core.DeckStatus status;
  final int numberOfCards;

  XDeckPrivacyBottomSheet(this.status, this.numberOfCards);

  @override
  _XDeckPrivacyBottomSheetState createState() =>
      _XDeckPrivacyBottomSheetState(status);
}

class _XDeckPrivacyBottomSheetState extends State<XDeckPrivacyBottomSheet> {
  core.DeckStatus status;

  _XDeckPrivacyBottomSheetState(this.status);

  @override
  Widget build(BuildContext context) {
    return XedSheets.bottomSheet(
      context,
      'Select Privacy',
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioListTile<core.DeckStatus>(
              groupValue: status ?? core.DeckStatus.Protected,
              value: core.DeckStatus.Protected,
              onChanged: (core.DeckStatus value) => XError.f0(() {
                setState(() {
                  status = core.DeckStatus.Protected;
                });
                _onSelected();
              }),
              title: Text(
                'Only me',
                style: SemiBoldTextStyle(18).copyWith(
                  height: 1.4,
                  fontSize: 18,
                ),
              ),
              activeColor: Colors.black,
            ),
            Opacity(
              opacity: _canBePublished() ? 1.0 : 0.2,
              child: RadioListTile<core.DeckStatus>(
                groupValue: status ?? core.DeckStatus.Protected,
                value: core.DeckStatus.Published,
                onChanged: _canBePublished()
                    ? (core.DeckStatus value) => XError.f0(() {
                          setState(() {
                            status = core.DeckStatus.Published;
                          });
                          _onSelected();
                        })
                    : null,
                title: Text(
                  'Public',
                  style: SemiBoldTextStyle(18).copyWith(
                    height: 1.4,
                    fontSize: 18,
                  ),
                ),
                activeColor: Colors.black,
              ),
            ),
            _canBePublished()
                ? SizedBox()
                : Padding(
                    padding: EdgeInsets.only(
                      left: wp(30),
                      right: wp(30),
                      top: hp(13),
                    ),
                    child: Text(
                      core.Config.getString("msg_public_deck_rule"),
                      style: RegularTextStyle(14).copyWith(
                        color: XedColors.battleShipGrey,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  bool _canBePublished() {
    return widget.numberOfCards >= 5;
  }

  void _onSelected() {
    Navigator.of(context).pop(status);
  }
}
