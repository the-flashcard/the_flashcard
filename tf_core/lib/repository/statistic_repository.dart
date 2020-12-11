import 'package:tf_core/tf_core.dart';

abstract class StatisticRepository {
  Future<LineData> getLearningTime(int dayInterval, int fromTime, int toTime);

  Future<Map<String, int>> getCardReport(
      int dayInterval, int fromTime, int toTime);
}

class StatisticRepositoryImpl extends StatisticRepository {
  final HttpClient _client;

  StatisticRepositoryImpl(this._client);

  @override
  Future<Map<String, int>> getCardReport(
      int interval, int fromTime, int toTime) {
    Map<String, dynamic> params = {
      "interval": interval,
      "from_time": fromTime,
      "to_time": toTime
    };
    return _client.get("/statistic/card_report", params: params).then((data) {
      return (data as Map<String, dynamic>).cast<String, int>();
    });
  }

  @override
  Future<LineData> getLearningTime(int interval, int fromTime, int toTime) {
    Map<String, dynamic> params = {
      "interval": interval,
      "from_time": fromTime,
      "to_time": toTime
    };
    return _client.get('/statistic/learning_time', params: params).then((data) {
      return LineData.fromJson(data);
    });
  }
}
