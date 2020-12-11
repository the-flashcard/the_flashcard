import 'package:tf_core/tf_core.dart';

export 'google_search_image_repository.dart';

abstract class SearchImageRepository {
  Future<List<ImageRecord>> search(String query,
      {int from = 0, int count = 10});
}
