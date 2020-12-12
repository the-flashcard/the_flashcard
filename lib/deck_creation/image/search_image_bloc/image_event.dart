
abstract class ImageEvent  {
  int count;
}

class QueryChanged extends ImageEvent {
  final String query;
  QueryChanged({this.query});

  @override
  String toString() => 'QueryChanged';
}

class Refresh extends ImageEvent {

  @override
  String toString() => 'Refresh';
}

class LoadMore extends ImageEvent {

  @override
  String toString() => 'LoadMore';
}

class SelectImageAtEvent extends ImageEvent {
  final int index;

  SelectImageAtEvent(this.index);

  @override
  String toString() => "SelectImageEvent: $index";
}


class DeselectImageAtEvent extends ImageEvent {
  final int index;

  DeselectImageAtEvent(this.index);

  @override
  String toString() => "DeselectImageAtEvent: $index";
}