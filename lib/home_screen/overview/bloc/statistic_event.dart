part of 'statistic_bloc.dart';

@immutable
abstract class StatisticEvent {}

class ChangeTimePeriod extends StatisticEvent {
  final StatsTimePeriod period;

  ChangeTimePeriod(this.period);
}

class LoadStats extends StatisticEvent {}

class LoadNewCardLeaderboard extends StatisticEvent {}
