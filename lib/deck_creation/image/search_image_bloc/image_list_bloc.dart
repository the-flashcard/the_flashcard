import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:tf_core/tf_core.dart';

import 'image_event.dart';

class ImageListState {
  String query;
  int total;
  final List<ImageRecord> images;

  ImageListState(this.total, this.images, this.query);

  ImageListState.empty()
      : total = 0,
        images = [];

  bool get canLoadMore => images.length < total;

  bool get hasQueryFilter => query != null && query.trim().isNotEmpty;

  bool get hasNoData => images.isEmpty && !hasQueryFilter;

  @override
  String toString() => 'ImageListState: $query';
}

class ImageListLoading extends ImageListState {
  ImageListLoading(total, images, query) : super(total, images, query);

  @override
  String toString() => 'ImageLoading';
}

class ImageListError extends ImageListState {
  final String errorMessage;

  ImageListError(
    int total,
    List<ImageRecord> images,
    String query,
    this.errorMessage,
  ) : super(total, images, query);
}

class ImageListBloc extends Bloc<ImageEvent, ImageListState> {
  static const int MAX_SEARCH_IMAGE_COUNT = 30;
  final int pageSize;
  final Set<String> selectedImages = {};
  final List<ImageRecord> images = [];

  ImageListBloc(this.pageSize);

  @override
  ImageListState get initialState => ImageListState.empty();

  @override
  Stream<ImageListState> mapEventToState(ImageEvent event) async* {
    switch (event.runtimeType) {
      case QueryChanged:
        yield* _updateQuery(event);
        break;
      case Refresh:
        yield* _refreshSearch();
        break;
      case LoadMore:
        yield* _loadMore(event);
        break;
    }
  }

  Stream<ImageListState> _updateQuery(QueryChanged event) async* {
    state.query = event.query;
    yield* _refreshSearch();
  }

  Stream<ImageListState> _refreshSearch() async* {
    yield ImageListLoading(
      max(images.length, MAX_SEARCH_IMAGE_COUNT),
      images,
      state.query,
    );
    try {
      SearchImageService searchImageService = DI.get(SearchImageService);
      var r = await searchImageService.search(state.query, from: 0, count: 10);
      images.clear();
      selectedImages.clear();
      images.addAll(r);
      yield ImageListState(
        max(images.length, MAX_SEARCH_IMAGE_COUNT),
        images,
        state.query,
      );
    } catch (e) {
      Log.error("Error when search images: ${this.runtimeType} - $e");
      yield ImageListError(
        images.length,
        images,
        state.query,
        "No have data! Please try again.",
      );
    }
  }

  Stream<ImageListState> _loadMore(LoadMore event) async* {
    try {
      if (images.length < MAX_SEARCH_IMAGE_COUNT) {
        yield ImageListLoading(
          max(images.length, MAX_SEARCH_IMAGE_COUNT),
          images,
          state.query,
        );

        SearchImageService searchImageService = DI.get(SearchImageService);
        var r = await searchImageService.search(state.query,
            from: images.length, count: 10);
        images.addAll(r);
        yield ImageListState(
          max(images.length, MAX_SEARCH_IMAGE_COUNT),
          images,
          state.query,
        );
      }
    } catch (e) {
      Log.error("Error when search images: ${this.runtimeType} - $e");
      yield ImageListError(
        images.length,
        images,
        state.query,
        "No have data! Please try again.",
      );
    }
  }
}
