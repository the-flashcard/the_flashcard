import 'package:tf_core/tf_core.dart';

class GenerateInfo {
  int cardVersion;
  List<Container> fronts;
  Container back;

  GenerateInfo({this.cardVersion, this.fronts, this.back});

  GenerateInfo.fromJson(Map<String, dynamic> json) {
    if (json['card_version'] != null) this.cardVersion = json['card_version'];
    if (json['fronts'] != null) {
      this.fronts = [];
      json['fronts'].forEach((front) => fronts.add(Container.fromJson(front)));
    }

    if (json['back'] != null) {
      back = Container.fromJson(json['back']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.cardVersion != null) data['card_version'] = this.cardVersion;
    if (this.fronts != null) {
      data['fronts'] = fronts.map((front) => front.toJson()).toList();
    }
    if (back != null) data['back'] = back.toJson();
    return data;
  }
}
