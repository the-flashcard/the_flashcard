import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class StatisticService {
  Future<LineData> getLearningTime(int dayInterval, int fromTime, int toTime);

  Future<Map<String, int>> getCardReport(
      int dayInterval, int fromTime, int toTime);
}

class StatisticServiceImpl implements StatisticService {
  StatisticRepository _statisticRepository;

  StatisticServiceImpl(this._statisticRepository);

  @override
  Future<Map<String, int>> getCardReport(
      int dayInterval, int fromTime, int toTime) {
    return _statisticRepository.getCardReport(dayInterval, fromTime, toTime);
  }

  @override
  Future<LineData> getLearningTime(int dayInterval, int fromTime, int toTime) {
    return _statisticRepository.getLearningTime(dayInterval, fromTime, toTime);
  }
}
