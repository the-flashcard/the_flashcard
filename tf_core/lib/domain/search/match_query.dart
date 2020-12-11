class MatchQuery {
  String field;
  String value;
  String defaultOperator = "and";

  MatchQuery(this.field, this.value);

  MatchQuery.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    value = json['value'];
    defaultOperator = json['default_operator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['field'] = this.field;
    data['value'] = this.value;
    data['default_operator'] = this.defaultOperator;
    return data;
  }
}
