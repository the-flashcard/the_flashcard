import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tf_core/tf_core.dart' show Config;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';
import 'package:the_flashcard/home_screen/report_time_interval_picker.dart';
import 'package:the_flashcard/home_screen/welcome_page.dart';

class StatisticTab extends StatelessWidget {
  final StatisticBloc statisticBloc;
  StatisticTab(this.statisticBloc, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
      ),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            child: Image.asset('assets/backgrounds/shutterstock_294168236.png'),
            alignment: Alignment.centerRight,
          ),
          Container(
            margin: EdgeInsets.only(left: wp(20)),
            child: Column(
              children: <Widget>[
                ReportTimeIntervalPicker(statisticBloc),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text('Overview', style: SemiBoldTextStyle(16)),
                ),
                BlocBuilder<StatisticBloc, StatisticState>(
                  cubit: statisticBloc,
                  builder: (context, statisticState) {
                    var done = statisticState.doneCards;
                    var learning = statisticState.learningCards;
                    var news = statisticState.newCards;

                    return Container(
                      margin: EdgeInsets.only(right: wp(22), top: hp(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _overviewParameter('New words', news.toString()),
                          _overviewParameter('Learning', learning.toString()),
                          _overviewParameter('Completed', done.toString()),
                        ],
                      ),
                    );
                  },
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: hp(26), top: 20),
                  child: RichText(
                    text: TextSpan(
                      text: Config.getString("msg_well_done"),
                      style: ColorTextStyle(
                        fontSize: 14,
                        color: XedColors.battleShipGrey,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: ' -> Review',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => XError.f1(_gotoReviewPage, context),
                          style: ColorTextStyle(
                            fontSize: 14,
                            color: XedColors.waterMelon,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _gotoReviewPage(BuildContext context) {
    BlocProvider.of<PageNavigatorBloc>(context).add(GotoReviewPage());
  }
}

Widget _overviewParameter(String title, String value) {
  double height13 = hp(13);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        value ?? '0',
        style: SemiBoldTextStyle(24),
      ),
      Container(
        margin: EdgeInsets.only(top: height13),
        child: Text(
          title,
          style: ColorTextStyle(
            fontSize: 12,
            color: XedColors.battleShipGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}
