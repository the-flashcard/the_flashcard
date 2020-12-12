import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:flutter/widgets.dart' as ui;
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/common/notification/notification_bloc.dart';
import 'package:the_flashcard/common/xwidgets/x_flipper_widget.dart';
import 'package:the_flashcard/deck_screen/deck_bloc.dart';

import 'design_card_event.dart';
import 'upload_state.dart';

enum DesignStatus { Design, Saving, Saved, Edit }

abstract class DesignState extends UploadState {
  DesignState([List props = const []]) : super(props);
}

class DesignInitState extends DesignState {
  DesignInitState() : super([]);
}

abstract class CardSideChanged extends DesignState {
  final bool isFront;
  final int sideIndex;

  CardSideChanged(this.isFront, this.sideIndex)
      : super([isFront, sideIndex, DateTime.now().millisecondsSinceEpoch]);
}

class CardSideAdded extends CardSideChanged {
  CardSideAdded(bool isFront, int sideIndex) : super(isFront, sideIndex);
}

class CardSideReset extends CardSideChanged {
  CardSideReset(bool isFront, int sideIndex) : super(isFront, sideIndex);
}

class CardSideRemoved extends CardSideChanged {
  CardSideRemoved(bool isFront, int sideIndex) : super(isFront, sideIndex);
}

class CardSideUpdated extends CardSideChanged {
  CardSideUpdated(bool isFront, int sideIndex) : super(isFront, sideIndex);
}

abstract class ComponentChanged extends DesignState {
  final bool isFront;
  final int sideIndex;
  final int index;

  ComponentChanged(this.isFront, this.sideIndex, this.index)
      : super(
            [isFront, sideIndex, index, DateTime.now().millisecondsSinceEpoch]);
}

class ComponentAdded extends ComponentChanged {
  ComponentAdded(bool isFront, int sideIndex, int index)
      : super(isFront, sideIndex, index);
}

class ComponentUpdated extends ComponentChanged {
  ComponentUpdated(bool isFront, int sideIndex, int index)
      : super(isFront, sideIndex, index);
}

class ComponentRemoved extends ComponentChanged {
  ComponentRemoved(bool isFront, int sideIndex, int index)
      : super(isFront, sideIndex, index);
}

class ComponentMoved extends ComponentChanged {
  final int toIndex;

  ComponentMoved(bool isFront, int sideIndex, int index, this.toIndex)
      : super(isFront, sideIndex, index);

  bool get isMoveUp => index > toIndex;
}

class ComponentEdited extends ComponentChanged {
  final Component component;

  ComponentEdited(bool isFront, int sideIndex, int index, this.component)
      : super(isFront, sideIndex, index);
}

class DesignSavingState extends DesignState {
  DesignSavingState() : super([]);
}

class DesignCompletedState extends DesignState {
  final Card card;

  DesignCompletedState(this.card) : super([card]);
}

class DesignFailureState extends DesignState {
  final String error;

  DesignFailureState(this.error) : super([error]);
}

class DesignCardBloc extends Bloc<DesignCardEvent, DesignState> {
  final NotificationBloc notificationBloc = DI.get(NotificationBloc);
  final AuthService authService = DI.get(AuthService);
  final DeckService deckService = DI.get(DeckService);
  final DeckBloc deckBloc;

  Card originCard;

  CardDesign design;
  int changeCount = 0;

  final List<List<ui.Key>> frontKeys = <List<ui.Key>>[];
  final List<ui.Key> backKeys = <ui.Key>[];

  final _flipControllers = <FlipController>[];

  DesignCardBloc.create(this.deckBloc) {
    design = CardDesign();
    design.createFrontIfEmpty();
    _initKeys();
  }

  DesignCardBloc.edit(this.deckBloc, this.originCard) {
    design = originCard?.design ?? CardDesign();
    design.createFrontIfEmpty();
    _initKeys();
  }

  @override
  DesignState get initialState => DesignInitState();

  void _initKeys() {
    design.fronts.forEach((front) {
      var keys = List.generate(front.getComponentCount(), (i) {
        return ui.UniqueKey();
      });
      frontKeys.add(keys);

      _flipControllers.add(FlipController(isFront: true));
    });

    for (int i = 0; i < design.back.getComponentCount(); i++) {
      backKeys.add(ui.UniqueKey());
    }
  }

  int getComponentCount(bool isFront, int currentSideIndex) {
    if (isFront)
      return design.getFront(currentSideIndex)?.getComponentCount() ?? 0;
    else
      return design.back?.getComponentCount() ?? 0;
  }

  bool hasChanges() {
    return changeCount > 0;
  }

  bool noEmptyFronts() {
    var emptyFronts = (this.design.fronts ?? <Container>[])
        .where((x) => x.getComponentCount() <= 0)
        .toList();
    return emptyFronts.isEmpty;
  }

  bool hasFronts() {
    return design.getFrontCount() > 0;
  }

  FlipController getFlipController(int sideIndex) {
    return _flipControllers[sideIndex];
  }

  ui.Key getKey(bool isFront, int sideIndex, int index) {
    if (isFront) {
      return frontKeys[sideIndex][index] ?? ui.UniqueKey();
    } else
      return backKeys[index] ?? ui.UniqueKey();
  }

  @override
  Stream<DesignState> mapEventToState(DesignCardEvent event) async* {
    switch (event.runtimeType) {
      case SaveDesign:
        yield* saveCardDesign(event);
        break;
      case CreateCardSide:
        yield* createCardSide(event);
        break;
      case UpdateColorCardSide:
        yield* updateColorCardSide(event);
        break;
      case UpdateAlignmentCardSide:
        yield* updateCardSideAlignment(event);
        break;
      case ResetCardSide:
        yield* resetCardSide(event);
        break;
      case DeleteCardSide:
        yield* deleteCardSide(event);
        break;
      case AddComponent:
        yield* addComponent(event);
        break;
      case MoveUp:
        yield* moveUp(event);
        break;
      case MoveDown:
        yield* moveDown(event);
        break;
      case DeleteComponent:
        yield* deleteComponent(event);
        break;
      case EditComponent:
        yield* editComponent(event);
        break;
      default:
        if (event is UpdateComponent) {
          yield* updateComponent(event);
        }
        break;
    }
  }

  bool validateCardCount() {
    return this.originCard.design.getFrontCount() > 0;
  }

  Stream<DesignState> saveCardDesign(SaveDesign event) async* {
    final fronts = (this.design.fronts ?? <Container>[])
        .where((x) => x.getComponentCount() > 0)
        .toList();
    final back = this.design?.back ?? Container();

    final design = CardDesign.fromDesign(fronts, back);

    if (design.getFrontCount() <= 0) {
      yield DesignFailureState('There is no card to save.');
    } else if (originCard != null) {
      yield* editCard(event.deckId, originCard.id, design);
    } else {
      yield* addCardToDeck(event.deckId, design);
    }
  }

  Stream<DesignState> addCardToDeck(String deckId, CardDesign design) async* {
    try {
      yield DesignSavingState();
      final username =
          await authService.getLoginData().then((x) => x.userInfo.username);
      final cardId =
          await deckService.addCard(deckId, CardVersion.V1000, design);

      final newCard = Card()
        ..id = cardId
        ..deckId = deckId
        ..design = design
        ..username = username
        ..updatedTime = DateTime.now().toUtc().millisecondsSinceEpoch
        ..createdTime = DateTime.now().toUtc().millisecondsSinceEpoch;

      deckBloc.add(CardAdded(cardId: cardId, card: newCard));
      yield DesignCompletedState(newCard);
    } on APIException catch (e) {
      switch (e.reason) {
        case ApiErrorReasons.NotAuthenticated:
          yield DesignFailureState(Config.getNotAuthenticatedMsg());
          break;
        default:
          yield DesignFailureState(
              'Can\'t add this new card: ${e.reason} - ${e.message}');
          break;
      }
    } catch (e) {
      yield DesignFailureState("Can't add this new card: ${e.toString()}");
    }
  }

  Stream<DesignState> editCard(
      String deckId, String cardId, CardDesign design) async* {
    try {
      yield DesignSavingState();
      final newCard = await deckService.editCard(cardId, design);

      deckBloc.add(CardUpdated(cardId: cardId, card: newCard));
      yield DesignCompletedState(newCard);
    } on APIException catch (error) {
      switch (error.reason) {
        case ApiErrorReasons.NotAuthenticated:
          yield DesignFailureState(Config.getNotAuthenticatedMsg());
          break;
        default:
          yield DesignFailureState(
              'Can\'t edit this card: ${error.reason} - ${error.message}');
          break;
      }
    } catch (e) {
      yield DesignFailureState("Can't edit this card: ${e.toString()}");
    }
  }

  Stream<DesignState> createCardSide(CreateCardSide event) async* {
    if (event.isFront) {
      design.addFronts([Container()]);
      this.changeCount++;
      frontKeys.add(<ui.UniqueKey>[]);
      _flipControllers.add(FlipController(isFront: true));
      yield CardSideAdded(
        event.isFront,
        design.getFrontCount() - 1,
      );
    }
  }

  Stream<DesignState> resetCardSide(ResetCardSide event) async* {
    if (event.isFront) {
      design.resetFrontFormat(event.sideIndex);
    } else {
      design.resetBackFormat();
    }
    this.changeCount++;
    yield CardSideReset(event.isFront, event.isFront ? event.sideIndex : 0);
  }

  Stream<DesignState> deleteCardSide(DeleteCardSide event) async* {
    if (event.isFront) {
      bool hasBack = (design.back?.getComponentCount() ?? 0) > 0;
      if (!hasBack) {
        design.deleteFront(event.sideIndex);
        frontKeys.removeAt(event.sideIndex);
        _flipControllers.removeAt(event.sideIndex);
      } else {
        design.clearFront(event.sideIndex);
      }
    } else {
      design.clearBack();
      backKeys.clear();
    }
    this.changeCount++;
    yield CardSideRemoved(
      event.isFront,
      event.isFront ? event.sideIndex : 0,
    );
  }

  Stream<DesignState> addComponent(AddComponent event) async* {
    try {
      if (event.isFront) {
        final front = design.getFront(event.sideIndex);
        if (front != null) {
          front.addComponent(event.componentData);
          this.changeCount++;
          frontKeys[event.sideIndex]?.add(ui.UniqueKey());
          yield ComponentAdded(
            event.isFront,
            event.sideIndex,
            front.getComponentCount() - 1,
          );
        }
      } else {
        if (event.componentData.isActionComponent) {
          throw Exception(
              "Can't add FillInBlank or Multi Choice to the back card!");
        }
        design.back.addComponent(event.componentData);
        this.changeCount++;

        backKeys.add(ui.UniqueKey());
        yield ComponentAdded(
          event.isFront,
          event.sideIndex,
          design.back.getComponentCount() - 1,
        );
      }
    } catch (e) {
      yield DesignFailureState('Error: ${e.message}');
    }
  }

  Stream<DesignState> updateComponent(UpdateComponent event) async* {
    if (event.isFront) {
      final front = design.getFront(event.sideIndex);
      if (front != null) {
        front.updateComponent(event.index, event.componentData);
        this.changeCount++;
        if (event.componentData is! Text)
          frontKeys[event.sideIndex][event.index] = ui.UniqueKey();
        yield ComponentUpdated(
          event.isFront,
          event.sideIndex,
          event.index,
        );
      }
    } else {
      design.back.updateComponent(event.index, event.componentData);
      this.changeCount++;
      if (event.componentData is! Text)
        frontKeys[event.sideIndex][event.index] = ui.UniqueKey();
      yield ComponentUpdated(
        event.isFront,
        event.sideIndex,
        event.index,
      );
    }
  }

  Stream<DesignState> deleteComponent(DeleteComponent event) async* {
    if (event.isFront) {
      final front = design.getFront(event.sideIndex);
      if (front != null) {
        front.deleteComponent(event.index);
        this.changeCount++;
        frontKeys[event.sideIndex]?.removeAt(event.index);
        yield ComponentRemoved(
          event.isFront,
          event.sideIndex,
          event.index,
        );
      }
    } else {
      design.back.deleteComponent(event.index);
      this.changeCount++;
      backKeys.removeAt(event.index);
      yield ComponentRemoved(
        event.isFront,
        event.sideIndex,
        event.index,
      );
    }
  }

  void _swapKey(bool isFront, int sideIndex, int fromIndex, int toIndex) {
    if (isFront) {
      ui.Key tmp = frontKeys[sideIndex][fromIndex];
      frontKeys[sideIndex][fromIndex] = frontKeys[sideIndex][toIndex];
      frontKeys[sideIndex][toIndex] = tmp;
    } else {
      ui.Key tmp = backKeys[fromIndex];
      backKeys[fromIndex] = backKeys[toIndex];
      backKeys[toIndex] = tmp;
    }
  }

  Stream<DesignState> moveUp(MoveUp event) async* {
    if (event.isFront) {
      final front = design.getFront(event.sideIndex);
      if (front != null) {
        int toIndex = max(event.index - 1, 0);
        front.moveComponent(event.index, toIndex);
        this.changeCount++;
        _swapKey(event.isFront, event.sideIndex, event.index, toIndex);

        yield ComponentMoved(
          event.isFront,
          event.sideIndex,
          event.index,
          toIndex,
        );
      }
    } else {
      int toIndex = max(event.index - 1, 0);
      design.back.moveComponent(event.index, toIndex);
      this.changeCount++;
      _swapKey(event.isFront, event.sideIndex, event.index, toIndex);

      yield ComponentMoved(
        event.isFront,
        event.sideIndex,
        event.index,
        toIndex,
      );
    }
  }

  Stream<DesignState> moveDown(MoveDown event) async* {
    if (event.isFront) {
      final front = design.getFront(event.sideIndex);
      if (front != null) {
        int toIndex = min(event.index + 1, front.getComponentCount() - 1);
        front.moveComponent(event.index, toIndex);
        this.changeCount++;
        _swapKey(event.isFront, event.sideIndex, event.index, toIndex);

        yield ComponentMoved(
          event.isFront,
          event.sideIndex,
          event.index,
          toIndex,
        );
      }
    } else {
      int toIndex = min(event.index + 1, design.back.getComponentCount() - 1);
      design.back?.moveComponent(event.index, toIndex);
      this.changeCount++;
      _swapKey(event.isFront, event.sideIndex, event.index, toIndex);
      yield ComponentMoved(
        event.isFront,
        event.sideIndex,
        event.index,
        toIndex,
      );
    }
  }

  Stream<DesignState> editComponent(EditComponent event) async* {
    Component component = event.isFront
        ? design.getFrontComponent(event.sideIndex, event.index)
        : design.getBackComponent(event.index);
    if (component != null)
      yield ComponentEdited(
        event.isFront,
        event.sideIndex,
        event.index,
        component,
      );
  }

  Stream<DesignState> updateColorCardSide(UpdateColorCardSide event) async* {
    Container cardSide = design.getCardSide(event.isFront, event.sideIndex);
    if (cardSide != null) {
      cardSide.backgroundColor = XGradientColor.fromGradient(event.background);
      this.changeCount++;
      yield CardSideUpdated(
        event.isFront,
        event.sideIndex,
      );
    }
  }

  Stream<DesignState> updateCardSideAlignment(
      UpdateAlignmentCardSide event) async* {
    Container container = design.getCardSide(event.isFront, event.sideIndex);
    if (container != null) {
      container.alignment = event.alignment.index;

      this.changeCount++;
      yield CardSideUpdated(
        event.isFront,
        event.sideIndex,
      );
    }
  }
}
