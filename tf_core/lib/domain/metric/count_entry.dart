class CountEntry {
  int time;
  int value;
  int hits;

  CountEntry({this.time = 0, this.value = 0, this.hits = 0});

  CountEntry.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    value = json['value'];
    hits = json['hits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['time'] = this.time;
    data['value'] = this.value;
    data['hits'] = this.hits;
    return data;
  }
}
