import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  CategoryEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class SearchGlobalCategory extends CategoryEvent {
  SearchGlobalCategory();

  @override
  String toString() => 'SearchGlobalCategory';
}

class CategorySelected extends CategoryEvent {
  final String categoryId;

  CategorySelected(this.categoryId);

  @override
  String toString() => 'CategorySelected';
}

class CategoryDeselected extends CategoryEvent {
  @override
  String toString() => 'CategoryDeselected';
}
