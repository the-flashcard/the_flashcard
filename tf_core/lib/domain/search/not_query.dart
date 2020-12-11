class NotQuery {
  String field;
  final List<String> values = [];

  NotQuery(this.field);

  NotQuery.from(field, values) {
    this.field = field;
    this.values.addAll(values);
  }

  NotQuery.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    if (json['values'] != null) {
      json['values'].forEach((v) => values.add(v));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['field'] = this.field;
    if (this.values != null) {
      data['values'] = this.values;
    }
    return data;
  }
}
