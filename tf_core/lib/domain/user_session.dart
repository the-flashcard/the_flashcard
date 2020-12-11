class UserSession {
  String key;
  String value;
  String domain;
  int timeoutInMs;
  String path;
  int maxAge;

  UserSession(
      {this.key,
      this.value,
      this.domain,
      this.timeoutInMs,
      this.path,
      this.maxAge});

  UserSession.fromJson(Map<String, dynamic> json) {
    this.key = json['key'];
    this.value = json['value'];
    this.domain = json['domain'];
    this.timeoutInMs = json['timeout_in_ms'];
    this.path = json['path'];
    this.maxAge = json['max_age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    data['domain'] = this.domain;
    data['timeout_in_ms'] = this.timeoutInMs;
    data['path'] = this.path;
    data['max_age'] = this.maxAge;
    return data;
  }
}
