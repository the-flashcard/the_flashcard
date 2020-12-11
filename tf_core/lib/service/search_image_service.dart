import 'package:tf_core/tf_core.dart';

abstract class SearchImageService {
  Future<List<ImageRecord>> search(String query,
      {int from = 0, int count = 10});
}

class SearchImageServiceImpl extends SearchImageService {
  final SearchImageRepository _searchImageRepository;

  SearchImageServiceImpl(this._searchImageRepository);

  @override
  Future<List<ImageRecord>> search(String query,
      {int from = 0, int count = 10}) {
    return _searchImageRepository.search(query, from: from, count: count);
  }
}
