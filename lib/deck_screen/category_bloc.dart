import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/deck_screen/category_event.dart';
import 'package:the_flashcard/deck_screen/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  @override
  CategoryState get initialState => NotLoaded();

  @override
  Stream<CategoryState> mapEventToState(CategoryEvent event) async* {
    switch (event.runtimeType) {
      case SearchGlobalCategory:
        final DeckService deckService = DI.get(DeckService);
        yield Loading();
        yield Loaded(await deckService.getDeckCategories());
        break;
      case CategorySelected:
        yield* _selectCategory(event);
        break;
      case CategoryDeselected:
        yield* _deselectCategory(event);
        break;
    }
  }

  Stream<CategoryState> _selectCategory(CategorySelected event) async* {
    if (state is Loaded) {
      yield Loaded((state as Loaded).result, categoryId: event.categoryId);
    }
  }

  Stream<CategoryState> _deselectCategory(CategoryDeselected event) async* {
    if (state is Loaded) {
      yield Loaded((state as Loaded).result, categoryId: null);
    }
  }
}
