import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_buttons.dart';
import 'package:the_flashcard/common/resources/xed_sheets.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/deck_screen/report_option.dart';
import 'package:the_flashcard/login/authentication/authentication_bloc.dart';

class ReportModalSheet extends StatefulWidget {
  final String deckId;
  final String cardId;

  ReportModalSheet({this.deckId, this.cardId});

  @override
  _ReportModalSheetState createState() => _ReportModalSheetState();
}

class _ReportModalSheetState extends State<ReportModalSheet> {
  AuthenticationBloc authBloc;

  List<String> feedbackOption = [
    'Not Interesting',
    'Copyright Infringement',
    'Has Error',
    'Inappropriate',
    'Other',
  ];

  List<bool> optionChosen;

  @override
  void initState() {
    super.initState();
    optionChosen = List.generate(feedbackOption.length, (index) => false);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  List<String> listReport() {
    List<String> chosenFeedback = [];
    for (int i = 0; i < feedbackOption.length; i++) {
      if (optionChosen[i] == true) {
        chosenFeedback.add(feedbackOption[i]);
      }
    }
    return chosenFeedback;
  }

  void callbackSetState() {
    setState(() {});
  }

  bool hasFeedback() {
    return !optionChosen.contains(true);
  }

  void sendFeedback() {
    Map<String, dynamic> feedback = {
      'not_interesting': optionChosen[0],
      'copyright': optionChosen[1],
      'has_error': optionChosen[2],
      'inappropriate': optionChosen[3],
      'other': optionChosen[4],
      'deck_id': widget.deckId,
      'card_id': widget.cardId,
    };
    logFeedback(feedback);
  }

  void logFeedback(Map<String, dynamic> params) {}

  @override
  Widget build(BuildContext context) {
    return XedSheets.bottomSheet(
      context,
      'What\'s Wrong?',
      Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.report,
                  color: XedColors.waterMelon,
                ),
                title: Text(
                  core.Config.getString("msg_leave_feedback"),
                  style: SemiBoldTextStyle(16).copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: wp(11)),
                child: Wrap(
                  children: List.generate(
                    feedbackOption.length,
                    (index) {
                      return ReportOption(
                        feedbackOption[index],
                        optionChosen,
                        index,
                        callbackSetState,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: wp(15), vertical: hp(3)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(18, 18, 18, 0.1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.report,
                      color: XedColors.duckEggBlue,
                    ),
                    title: Text(
                      core.Config.getString("msg_leave_opinion"),
                      maxLines: 3,
                      style: SemiBoldTextStyle(16).copyWith(
                        fontSize: 16,
                        color: XedColors.brownGrey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: hp(5)),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: wp(15)),
                      child: Opacity(
                        opacity: hasFeedback() ? 0.2 : 1.0,
                        child: XedButtons.watermelonButton(
                          'Send',
                          10,
                          18,
                          hasFeedback()
                              ? null
                              : () {
                                  sendFeedback();
                                  Navigator.of(context).pop();
                                  showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: XedColors.transparent,
                                        elevation: 0.0,
                                        content: Container(
                                          width: wp(295),
                                          height: hp(108),
                                          decoration: BoxDecoration(
                                            color: XedColors.white,
                                            borderRadius:
                                                BorderRadius.circular(hp(10)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    core.Config.getString(
                                                        "msg_feedback_thanks"),
                                                    style: BoldTextStyle(18)
                                                        .copyWith(
                                                            height: 1.4,
                                                            fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                              Divider(height: hp(1)),
                                              Expanded(
                                                child: InkWell(
                                                  child: Center(
                                                    child: Text(
                                                      'OK',
                                                      style: BoldTextStyle(18)
                                                          .copyWith(
                                                        color: XedColors
                                                            .waterMelon,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () => XError.f0(
                                                    Navigator.of(context).pop,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                          width: wp(335),
                          height: hp(56),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
