import 'package:tf_core/tf_core.dart';

class VotingDetail {
  final Map<String, VoteStatus> votes = {};
  final Map<String, VotingMetric> statistics = {};

  VotingDetail.fromJson(Map<String, dynamic> json) {
    if (json['votes'] != null) {
      json['votes'].forEach((k, v) {
        var statusList = VoteStatus.values.where((x) => x.index == v);
        votes[k] = statusList.isNotEmpty ? statusList.first : VoteStatus.None;
      });
    }

    if (json['statistics'] != null) {
      json['statistics'].forEach((k, v) {
        statistics[k] = VotingMetric.fromJson(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    if (this.votes != null)
      data['votes'] = this.votes.map((k, v) => MapEntry(k, v.index));
    if (this.statistics != null)
      data['statistics'] =
          this.statistics.map((k, v) => MapEntry(k, v.toJson()));
    return data;
  }
}
