import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';

part 'statistic_event.dart';
part 'statistic_state.dart';

enum StatsTimePeriod {
  Today,
  Last3Days,
  Last7Days,
  Last30Days,
}

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  int intervalInMin = Duration.minutesPerDay;
  int fromTime;
  int toTime;
  StatisticBloc() {
    _updatePeriod(StatsTimePeriod.Today);
  }
  @override
  StatisticState get initialState => StatisticState.init();

  @override
  Stream<StatisticState> mapEventToState(
    StatisticEvent event,
  ) async* {
    switch (event.runtimeType) {
      case ChangeTimePeriod:
        yield* _handleChangeTimePeriod(event);
        break;
      case LoadStats:
        yield* _handleLoadStats(event);
        break;
      default:
    }
  }

  Stream<StatisticState> _handleChangeTimePeriod(
      ChangeTimePeriod event) async* {
    try {
      var newState = state.copyWith(timePeriodSelect: event.period);
      _updatePeriod(event.period);
      yield ChangeTimeSuccess.from(newState);
    } catch (ex, trace) {
      Log.error("$runtimeType - Error: $ex \n trace: $trace");
      yield StatisticError.from(state, message: _getMessageFromError(ex));
    }
  }

  Stream<StatisticState> _handleLoadStats(LoadStats event) async* {
    try {
      yield StatisticLoading.from(state);
      final StatisticService statisticService = DI.get(StatisticService);
      Map<String, dynamic> statisticData = await statisticService.getCardReport(
        intervalInMin,
        fromTime,
        toTime + Duration.millisecondsPerDay - 1,
      );
      yield StatisticState.from(state.copyWith(statisticReport: statisticData));
    } catch (ex, strace) {
      Log.error("$runtimeType - Error: $ex \n Stace: $strace");
      yield StatisticError.from(state, message: _getMessageFromError(ex));
    }
  }

  void _updatePeriod(StatsTimePeriod period) {
    int gapDays = 3;
    switch (period) {
      case StatsTimePeriod.Today:
        gapDays = 1;
        break;
      case StatsTimePeriod.Last3Days:
        gapDays = 3;
        break;
      case StatsTimePeriod.Last7Days:
        gapDays = 6;
        break;
      case StatsTimePeriod.Last30Days:
        gapDays = 29;
        break;
      default:
        gapDays = 6;
        break;
    }
    toTime = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).millisecondsSinceEpoch;

    fromTime = DateTime.fromMillisecondsSinceEpoch(toTime, isUtc: true)
        .subtract(Duration(days: gapDays))
        .millisecondsSinceEpoch;
  }

  String _getMessageFromError(dynamic ex) {
    switch (ex.runtimeType) {
      case APIException:
        return (ex as APIException).message;
        break;
      default:
        return Config.getMessageError();
    }
  }
}
