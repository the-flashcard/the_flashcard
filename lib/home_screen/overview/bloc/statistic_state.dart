part of 'statistic_bloc.dart';

class StatisticState {
  static const LearningLabel = "learning_card_count";
  static const DoneLabel = "completed_card_count";
  static const NewsLabel = "new_card_count";
  static const IgnoreLabel = "ignored_card_count";

  final StatsTimePeriod timePeriodSelect;

  final Map<String, int> statisticReport;

  StatisticState(
    this.timePeriodSelect,
    this.statisticReport,
  );

  StatisticState.from(StatisticState state)
      : timePeriodSelect = state.timePeriodSelect,
        statisticReport = state.statisticReport;

  StatisticState.init()
      : timePeriodSelect = StatsTimePeriod.Today,
        statisticReport = {};

  StatisticState copyWith({
    StatsTimePeriod timePeriodSelect,
    Map<String, int> statisticReport,
  }) {
    return StatisticState(
      timePeriodSelect ?? this.timePeriodSelect,
      statisticReport ?? this.statisticReport,
    );
  }

  int get doneCards =>
      (statisticReport[DoneLabel] ?? 0) + (statisticReport[IgnoreLabel] ?? 0);

  int get newCards => statisticReport[NewsLabel] ?? 0;

  int get learningCards => statisticReport[LearningLabel] ?? 0;
}

class StatisticLoading extends StatisticState {
  StatisticLoading.from(StatisticState state)
      : super(
          state.timePeriodSelect,
          state.statisticReport,
        );
}

class StatisticError extends StatisticState {
  final String message;
  StatisticError.from(StatisticState state, {this.message = ''})
      : super(
          state.timePeriodSelect,
          state.statisticReport,
        );
}

class ChangeTimeSuccess extends StatisticState {
  ChangeTimeSuccess.from(StatisticState state)
      : super(
          state.timePeriodSelect,
          state.statisticReport,
        );
}
