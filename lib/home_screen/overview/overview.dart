import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/home_screen/overview/bloc/statistic_bloc.dart';
import 'package:the_flashcard/home_screen/overview/statistic_tab.dart';

class Overview extends StatefulWidget {
  Overview({Key key}) : super(key: key);

  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  StatisticBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = DI.get(StatisticBloc);
  }

  @override
  Widget build(BuildContext context) {
    Widget statisticTab = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: StatisticTab(bloc),
    );

    return BlocListener<StatisticBloc, StatisticState>(
      bloc: bloc,
      listener: _handleOnStateChange,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Container(
          height: 246,
          child: Swiper.children(
            viewportFraction: 0.95,
            loop: false,
            children: <Widget>[
              statisticTab,
            ],
          ),
        ),
      ),
    );
  }

  void _handleOnStateChange(BuildContext context, StatisticState state) {
    if (state is ChangeTimeSuccess) {
      bloc..add(LoadNewCardLeaderboard())..add(LoadStats());
    }
    if (state is StatisticError) {
      DI
          .get<NotificationBloc>(NotificationBloc)
          .add(ErrorNotification(state.message));
    }
  }
}
