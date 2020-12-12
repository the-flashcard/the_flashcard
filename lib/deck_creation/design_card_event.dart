import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tf_core/tf_core.dart';

import 'upload_event.dart';

abstract class DesignCardEvent extends UploadEvent {}

class SaveDesign extends DesignCardEvent {
  final String deckId;

  SaveDesign(this.deckId);
}

class CreateCardSide extends DesignCardEvent {
  final bool isFront;

  CreateCardSide({this.isFront = true});

  @override
  String toString() {
    return '${runtimeType.toString()}: $isFront';
  }
}

class ResetCardSide extends DesignCardEvent {
  final bool isFront;
  final int sideIndex;

  ResetCardSide({this.isFront = true, @required this.sideIndex});

  @override
  String toString() {
    return '${runtimeType.toString()}: $isFront';
  }
}

class DeleteCardSide extends DesignCardEvent {
  final bool isFront;
  final int sideIndex;

  DeleteCardSide({this.isFront = true, @required this.sideIndex});

  @override
  String toString() {
    return '${runtimeType.toString()}: $isFront - $sideIndex';
  }
}

class UpdateColorCardSide extends DesignCardEvent {
  final bool isFront;
  final int sideIndex;
  final LinearGradient background;

  UpdateColorCardSide({
    this.isFront = true,
    @required this.sideIndex,
    @required this.background,
  });

  @override
  String toString() {
    return '${runtimeType.toString()}: $isFront - $sideIndex';
  }
}

class UpdateAlignmentCardSide extends DesignCardEvent {
  final bool isFront;
  final int sideIndex;
  final XCardAlignment alignment;

  UpdateAlignmentCardSide({
    this.isFront = true,
    @required this.sideIndex,
    @required this.alignment,
  });

  @override
  String toString() {
    return '${runtimeType.toString()}: $isFront - $sideIndex';
  }
}

abstract class ComponentChanged extends DesignCardEvent {
  final bool isFront;
  final int sideIndex;

  ComponentChanged(
    this.isFront,
    this.sideIndex,
  );
}

class AddComponent<T extends Component> extends ComponentChanged {
  final T componentData;

  AddComponent({
    @required bool isFront,
    @required int sideIndex,
    @required this.componentData,
  }) : super(isFront, sideIndex);
}

class UpdateComponent<T extends Component> extends ComponentChanged {
  final int index;
  final T componentData;

  UpdateComponent({
    @required bool isFront,
    @required int sideIndex,
    @required this.index,
    @required this.componentData,
  }) : super(isFront, sideIndex);
}

class MoveUp extends ComponentChanged {
  final int index;

  MoveUp({
    @required bool isFront,
    @required int sideIndex,
    @required this.index,
  }) : super(isFront, sideIndex);
}

class MoveDown extends ComponentChanged {
  final int index;

  MoveDown({
    @required bool isFront,
    @required int sideIndex,
    @required this.index,
  }) : super(isFront, sideIndex);
}

class DeleteComponent extends ComponentChanged {
  final int index;

  DeleteComponent({
    @required bool isFront,
    @required int sideIndex,
    @required this.index,
  }) : super(isFront, sideIndex);
}

class EditComponent extends ComponentChanged {
  final int index;

  EditComponent({
    @required bool isFront,
    @required int sideIndex,
    @required this.index,
  }) : super(isFront, sideIndex);
}
