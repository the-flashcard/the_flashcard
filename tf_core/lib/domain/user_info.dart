class UserInfo {
  String username;
  List<int> roles = [];
  bool isActive;
  int createTime;

  UserInfo({this.username, this.roles, this.isActive, this.createTime});

  UserInfo.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    if (json['roles'] != null) {
      json['roles'].forEach((v) {
        roles.add(v);
      });
    }
    isActive = json['is_active'];
    createTime = json['create_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['username'] = this.username;
    if (this.roles != null) {
      data['roles'] = this.roles;
    }
    data['is_active'] = this.isActive;
    data['create_time'] = this.createTime;
    return data;
  }
}
