import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_sheets.dart';
import 'package:the_flashcard/deck_screen/report_modal_sheet.dart';

class ShareFeedbackBottomSheetWidget extends StatelessWidget {
  final core.Deck deck;

  ShareFeedbackBottomSheetWidget({this.deck});

  @override
  Widget build(BuildContext context) {
    return XedSheets.bottomSheet(
      context,
      'More',
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.share),
              title: Padding(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  'Share to',
                  style: SemiBoldTextStyle(16).copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              onTap: () async =>
                  await _onSharePressed(context, deckId: deck.id),
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Padding(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  'Give feedback or report',
                  style: SemiBoldTextStyle(16).copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              onTap: () => XError.f0(() => _onFeedbackPressed(context)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSharePressed(
    BuildContext context, {
    String deckId = '',
  }) async {
    try {
      Navigator.of(context).pop();
    } catch (ex) {
      core.Log.error(ex);
    }
  }

  void _onFeedbackPressed(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      backgroundColor: XedColors.transparent,
      context: context,
      builder: (BuildContext context) => ReportModalSheet(),
    ).catchError((ex) => core.Log.error(ex));
  }
}
