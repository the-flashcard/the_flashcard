import 'package:tf_core/tf_core.dart';

class CardDesign {
  final List<Container> fronts = [];
  Container back = Container();

  CardDesign();

  CardDesign.from(CardDesign design) {
    if (design?.fronts != null) {
      design.fronts.forEach((front) {
        fronts.add(Container.from(front));
      });
    }

    if (design?.back != null) {
      back = Container.from(design.back);
    }
  }

  CardDesign.fromDesign(List<Container> fronts, this.back) {
    this.fronts.addAll(fronts);
  }

  CardDesign addFronts(List<Container> fronts) {
    this.fronts.addAll(fronts);
    return this;
  }

  CardDesign.fromJson(Map<String, dynamic> json) {
    if (json['fronts'] != null) {
      json['fronts'].forEach((front) => fronts.add(Container.fromJson(front)));
    }

    if (json['back'] != null) {
      back = Container.fromJson(json['back']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.fronts != null) {
      data['fronts'] = fronts.map((front) => front.toJson()).toList();
    }
    if (back != null) data['back'] = back.toJson();
    return data;
  }

  Container getFront(int sideIndex) {
    if (sideIndex >= 0 && sideIndex < fronts.length)
      return fronts[sideIndex];
    else
      return null;
  }

  Container getCardSide(bool isFront, int sideIndex) {
    return isFront ? getFront(sideIndex) : back;
  }

  Component getFrontComponent(int sideIndex, int index) {
    if (sideIndex >= 0 && sideIndex < fronts.length)
      return fronts[sideIndex].components[index];
    else
      return null;
  }

  Component getBackComponent(int index) {
    if (back != null && index < back.components.length)
      return back.components[index];
    else
      return null;
  }

  CardDesign deleteFront(int sideIndex) {
    if (sideIndex >= 0 && sideIndex < fronts.length) {
      fronts.removeAt(sideIndex);
    }
    return this;
  }

  CardDesign clearFront(int sideIndex) {
    if (sideIndex >= 0 && sideIndex < fronts.length) {
      fronts[sideIndex] = Container();
    }
    return this;
  }

  CardDesign resetFrontFormat(int sideIndex) {
    if (sideIndex >= 0 && sideIndex < fronts.length) {
      fronts[sideIndex].backgroundColor = XGradientColor.init();
      fronts[sideIndex].alignment = XCardAlignment.Center.index;
    }
    return this;
  }

  CardDesign resetBackFormat() {
    back?.backgroundColor = XGradientColor.init();
    back?.alignment = XCardAlignment.Center.index;
    return this;
  }

  CardDesign clearBack() {
    back = Container();
    return this;
  }

  int getFrontCount() {
    return fronts?.length ?? 0;
  }

  void createFrontIfEmpty() {
    if (this.getFrontCount() <= 0) {
      this.addFronts([Container()]);
    }
  }
}
