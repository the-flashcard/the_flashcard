import 'package:flutter/material.dart';
import 'package:the_flashcard/deck_creation/multi_choice/bloc/multi_choice_bloc.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';
import 'package:the_flashcard/home_screen/stats_period_bottom_sheet.dart';

class ReportTimeIntervalPicker extends StatefulWidget {
  final StatisticBloc bloc;

  ReportTimeIntervalPicker(this.bloc);

  @override
  _ReportTimeIntervalPickerState createState() =>
      _ReportTimeIntervalPickerState();
}

class _ReportTimeIntervalPickerState extends State<ReportTimeIntervalPicker> {
  final List<String> periodAsTexts = [
    'Today',
    'Last 3 days',
    'Last 7 days',
    'Last 30 days',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticBloc, StatisticState>(
      cubit: widget.bloc,
      builder: (context, statisticState) {
        return Container(
          margin: EdgeInsets.only(top: 13),
          child: Row(
            children: <Widget>[
              Spacer(),
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Row(
                    children: <Widget>[
                      Text(periodAsTexts[
                          widget.bloc.state.timePeriodSelect.index]),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                onTap: () => _showStatsTimePeriodBottomSheet(context),
              )
            ],
          ),
        );
      },
    );
  }

  void _showStatsTimePeriodBottomSheet(context) async {
    var period = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatsPeriodBottomSheet(
          selectedItem:
              widget.bloc.state.timePeriodSelect ?? StatsTimePeriod.Today,
        );
      },
    );

    if (period != null) {
      widget.bloc.add(ChangeTimePeriod(period));
    }
  }
}
