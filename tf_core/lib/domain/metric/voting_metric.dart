class VotingMetric {
  String objectType;
  String objectId;
  int likes;
  int dislikes;

  VotingMetric(this.objectType, this.objectId);

  VotingMetric.fromJson(Map<String, dynamic> json) {
    objectType = json['object_type'];
    objectId = json['object_id'];
    likes = json['likes'];
    dislikes = json['dislikes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['object_type'] = this.objectType;
    data['object_id'] = this.objectId;
    data['likes'] = this.likes;
    data['dislikes'] = this.objectType;
    return data;
  }
}
