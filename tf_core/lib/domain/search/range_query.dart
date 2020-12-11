class RangeQuery {
  String field;
  String lowValue;
  bool lowIncluded;
  String highValue;
  bool highIncluded;

  RangeQuery(this.field, this.lowValue, this.lowIncluded, this.highValue,
      this.highIncluded);

  RangeQuery.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    lowValue = json['low_value'];
    lowIncluded = json['low_included'];
    highValue = json['high_value'];
    highIncluded = json['high_included'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['field'] = this.field;
    if (lowValue != null) {
      data['low_value'] = lowValue;
      data['low_included'] = lowIncluded;
    }
    if (highValue != null) {
      data['high_value'] = highValue;
      data['high_included'] = highIncluded;
    }
    return data;
  }
}
