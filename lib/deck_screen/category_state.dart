import 'package:equatable/equatable.dart';
import 'package:tf_core/tf_core.dart';

abstract class CategoryState extends Equatable {
  CategoryState([this.props = const []]);
  @override
  final List<Object> props;
}

class NotLoaded extends CategoryState {
  @override
  String toString() => 'NotLoaded';
}

class Loading extends CategoryState {
  @override
  String toString() => 'Loading';
}

class Loaded extends CategoryState {
  final String categoryId;
  final List<DeckCategory> result;

  Loaded(this.result, {this.categoryId}) : super([result, categoryId]);

  @override
  String toString() => 'Loaded';
}
