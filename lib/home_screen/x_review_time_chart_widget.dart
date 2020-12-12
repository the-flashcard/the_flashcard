import 'package:charts_flutter/flutter.dart' as chart;
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/resources/xed_colors.dart';

class XReviewTimeChart extends StatelessWidget {
  final int fromTime;
  final int toTime;
  final core.LineData reviewTime;

  XReviewTimeChart({
    @required this.fromTime,
    @required this.toTime,
    this.reviewTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
//      height: height,
//      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: chart.TimeSeriesChart(_buildSerieData(),
            animate: true,
            customSeriesRenderers: [
              chart.LineRendererConfig(
                customRendererId: 'review_time',
                includeArea: true,
                includeLine: true,
                stacked: false,
              ),
            ],
            behaviors: [
              chart.ChartTitle(
                'Review Time',
                behaviorPosition: chart.BehaviorPosition.top,
                titleStyleSpec: chart.TextStyleSpec(fontSize: 12),
                titleOutsideJustification:
                    chart.OutsideJustification.startDrawArea,
              ),
              chart.ChartTitle(
                'Second(s)',
                behaviorPosition: chart.BehaviorPosition.start,
                titleStyleSpec: chart.TextStyleSpec(fontSize: 10),
                titleOutsideJustification:
                    chart.OutsideJustification.middleDrawArea,
              )
            ],
            defaultRenderer: chart.LineRendererConfig(includePoints: false)),
      ),
    );
  }

  List<chart.Series<core.CountEntry, DateTime>> _buildSerieData() {
    // final random = new Random();

    var data = <core.CountEntry>[];
    var dataMap = <int, core.CountEntry>{};
    if (reviewTime != null) {
      reviewTime.records.forEach((e) {
        dataMap[e.time] = e;
      });
    }
    for (int time = fromTime;
        time <= toTime;
        time += Duration.millisecondsPerDay) {
      if (dataMap.containsKey(time))
        data.add(dataMap[time]);
      else
        data.add(core.CountEntry(time: time));
    }

    return [
      chart.Series<core.CountEntry, DateTime>(
        id: "review_time",
        displayName: "Review Time",
        data: data,
        domainFn: (data, time) =>
            DateTime.fromMillisecondsSinceEpoch(data.time, isUtc: true),
        measureFn: (data, time) => Duration(milliseconds: data.value).inSeconds,
        colorFn: (_, __) => chart.Color(
          r: XedColors.waterMelon.red,
          g: XedColors.waterMelon.green,
          b: XedColors.waterMelon.blue,
          a: 150,
        ),
      )..setAttribute(chart.rendererIdKey, 'review_time'),
    ];
  }
}
