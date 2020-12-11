import 'package:flutter/material.dart' as material;
import 'package:tf_core/tf_core.dart';

class Container extends Component {
  bool isHorizontal = false;
  XGradientColor backgroundColor = XGradientColor.init();
  int alignment = XCardAlignment.Center.index;
  final List<Component> components = [];

  Container()
      : alignment = XCardAlignment.Center.index,
        backgroundColor = XGradientColor.init(),
        super(Component.PanelType);

  Container.from(Container other) : super(Component.PanelType) {
    if (other is Container) {
      isHorizontal = other.isHorizontal ?? false;
      backgroundColor = other.backgroundColor ?? XGradientColor.init();
      alignment = other.alignment ?? XCardAlignment.Center.index;
      components.addAll(_cloneObject(other.components));
    }
  }

  List<Component> _cloneObject(List<Component> components) {
    return components != null
        ? components.map((component) => component.clone()).toList()
        : [];
  }

  int getComponentCount() {
    return components?.length ?? 0;
  }

  material.Gradient toGradient() {
    return this.backgroundColor.toGradient();
  }

  material.Alignment toAlignment() {
    switch (alignment) {
      case 0:
        return material.Alignment.topCenter;
      case 1:
        return material.Alignment.center;
      case 2:
        return material.Alignment.bottomCenter;
      default:
        return material.Alignment.topCenter;
    }
  }

  Container addComponent(Component componentData) {
    components.add(componentData);
    return this;
  }

  Container updateComponent(int index, Component componentData) {
    if (index >= 0 && index < components.length) {
      components[index] = componentData;
    }
    return this;
  }

  Container moveComponent(int fromIndex, int toIndex) {
    if (fromIndex >= 0 &&
        fromIndex < components.length &&
        toIndex >= 0 &&
        toIndex < components.length) {
      final temp = components[fromIndex];
      components[fromIndex] = components[toIndex];
      components[toIndex] = temp;
    }

    return this;
  }

  Container deleteComponent(int index) {
    if (index >= 0 && index < components.length) {
      components.removeAt(index);
    }

    return this;
  }

  bool hasActionComponent() {
    return components.where((component) {
      switch (component.runtimeType) {
        case FillInBlank:
        case MultiChoice:
        case MultiSelect:
          return true;
        default:
          return false;
      }
    }).isNotEmpty;
  }

  int countActionComponent() {
    return components.where((component) {
      switch (component.runtimeType) {
        case FillInBlank:
        case MultiChoice:
        case MultiSelect:
          return true;
        default:
          return false;
      }
    }).length;
  }

  Container.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['is_horizontal'] != null) isHorizontal = json['is_horizontal'];
    if (json['background_color'] != null && json['background_color'] is! int)
      backgroundColor = XGradientColor.fromJson(json['background_color']);
    else
      backgroundColor = XGradientColor.init();
    alignment = json['alignment'] ?? XCardAlignment.Center.index;

    if (json['components'] != null) {
      json['components'].forEach((component) {
        var x = Component.parseComponent(component);
        if (x != null) components.add(x);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.isHorizontal != null) data['is_horizontal'] = this.isHorizontal;
    if (this.backgroundColor != null)
      data['background_color'] = this.backgroundColor.toJson();
    if (this.isHorizontal != null)
      data['is_horizontal'] = this.isHorizontal ?? XCardAlignment.Center.index;

    data['alignment'] = alignment ?? XCardAlignment.Center.index;

    if (this.components != null) {
      List<dynamic> components = [];
      this
          .components
          .forEach((component) => components.add(component.toJson()));
      data['components'] = components;
    }

    return data;
  }

  @override
  Container clone() {
    return Container.from(this);
  }
}

enum XCardAlignment {
  Top,
  Center,
  Bottom,
}

//Becareful don't change item index
enum XGradientAlignment {
  TopLeft, //0
  BottomRight, //1
  CenterLeft, //2
  CenterRight, //3
}

class XGradientColor {
  List<int> colors;
  List<double> stops;
  int begin;
  int end;

  Map<int, material.Alignment> mapAlignments = {
    XGradientAlignment.TopLeft.index: material.Alignment.topLeft,
    XGradientAlignment.BottomRight.index: material.Alignment.bottomRight,
    XGradientAlignment.CenterLeft.index: material.Alignment.centerLeft,
    XGradientAlignment.CenterRight.index: material.Alignment.centerRight,
  };

  XGradientColor({
    this.colors = const [],
    this.stops = const [],
    this.begin,
    this.end,
  });

  XGradientColor.fromColor(List<material.Color> colors, {List<double> stops}) {
    this.colors = colors.map((color) => color.value).toList();
    if (stops == null) {
      if (colors.length == 1)
        stops = [1];
      else if (colors.length == 2) stops = [0, 1];
    }
    this.stops = stops;

    begin = XGradientAlignment.TopLeft.index;
    end = XGradientAlignment.BottomRight.index;
  }

  XGradientColor.init() {
    colors = [material.Colors.white.value];
    stops = [1];
    begin = XGradientAlignment.TopLeft.index;
    end = XGradientAlignment.BottomRight.index;
  }

  XGradientColor.defaultMessageBgColor() {
//    colors = [material.Colors.grey.value];
    colors = [material.Color.fromARGB(255, 255, 51, 102).value];
    stops = [1];
    begin = XGradientAlignment.TopLeft.index;
    end = XGradientAlignment.BottomRight.index;
  }

  XGradientColor.fromGradient(material.LinearGradient gradient) {
    this.colors = gradient.colors.map<int>((color) => color.value).toList();
    this.stops = gradient.stops;
    this.begin = toXGradientAlignment(gradient.begin);
    this.end = toXGradientAlignment(gradient.end);
  }

  material.Gradient toGradient() {
    return material.LinearGradient(
      colors: colors
          .map<material.Color>(
            (color) => material.Color(color),
          )
          .toList(),
      stops: stops,
      begin: toAlignment(begin),
      end: toAlignment(end),
    );
  }

  material.Alignment toAlignment(int index) {
    final material.Alignment alignment = mapAlignments[index];

    //Default
    return alignment ?? material.Alignment.topLeft;
  }

  int toXGradientAlignment(material.Alignment alignment) {
    if (alignment == material.Alignment.topLeft)
      return XGradientAlignment.TopLeft.index;
    if (alignment == material.Alignment.bottomRight)
      return XGradientAlignment.BottomRight.index;
    return XGradientAlignment.TopLeft.index;
  }

  XGradientColor.fromJson(Map<String, dynamic> json) {
    colors =
        (json['colors'] as List)?.cast<int>() ?? [material.Colors.white.value];

    stops = (json['stops'] as List)?.map((stop) {
          return double.tryParse(stop.toString());
        })?.toList() ??
        [1.0];

    begin = json['begin'] as int ?? XGradientAlignment.TopLeft.index;
    end = json['end'] as int ?? XGradientAlignment.BottomRight.index;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'colors': this.colors ?? [material.Colors.white.value],
      'stops': this.stops ?? [1.0],
      'begin': this.begin ?? XGradientAlignment.TopLeft.index,
      'end': this.end ?? XGradientAlignment.BottomRight.index,
    };
    return data;
  }
}
