import 'count_entry.dart';

class LineData {
  String label;
  int total;
  final List<CountEntry> records = [];

  LineData(this.label, this.total);

  LineData.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    total = json['total'];
    if (json['records'] != null) {
      json['records']
          .forEach((record) => records.add(CountEntry.fromJson(record)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['label'] = this.label;
    data['total'] = this.total;
    if (this.records != null) {
      List<dynamic> records = [];
      this.records.forEach((record) => records.add(record.toJson()));
      data['records'] = records;
    }
    return data;
  }

  @override
  String toString() {
    return "$runtimeType - {label: $label, total: $total}";
  }
}
