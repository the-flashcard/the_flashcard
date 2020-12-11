//class Panel extends Container {
//  String text = '';
//
//  Panel()
//
//  Panel.from(Panel panel) {
//    text = panel.text;
//  }
//
//  Panel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
//    text = json['text'] ?? '';
//  }
//
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = super.toJson();
//    if (this.text != null) data['text'] = this.text;
//    return data;
//  }
//
//  @override
//  Component clone() {
//    return Panel.from(this);
//  }
//}
