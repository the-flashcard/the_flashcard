class VotingInfo {
  String username;
  String objectType;
  String objectId;
  int vote;
  int updatedTime;
  int createdTime;

  VotingInfo.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    objectType = json['object_type'];
    objectId = json['object_id'];
    vote = json['vote'];
    updatedTime = json['updated_time'];
    createdTime = json['created_time'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['username'] = this.username;
    data['object_type'] = this.objectType;
    data['object_id'] = this.objectId;
    data['vote'] = this.vote;
    data['updated_time'] = this.updatedTime;
    data['created_time'] = this.createdTime;
    return data;
  }
}
