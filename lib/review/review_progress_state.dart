import 'package:equatable/equatable.dart';
import 'package:tf_core/tf_core.dart' as core;

class ReviewProgressState extends Equatable {
  final bool isSubmitted;
  final bool isNotRemember;
  final core.ReviewInfo reviewInfo;
  core.Card card;

  @override
  final List<Object> props;

  ReviewProgressState({
    this.isSubmitted = false,
    this.isNotRemember = false,
    this.reviewInfo,
  }) : props = const [];

  ReviewProgressState.empty()
      : props = const [],
        isSubmitted = false,
        isNotRemember = false,
        reviewInfo = null,
        card = null;
}

class ReviewProgressLoading extends ReviewProgressState {}
