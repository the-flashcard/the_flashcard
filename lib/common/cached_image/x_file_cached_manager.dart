import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class XFileCachedManager extends BaseCacheManager {
  final String name;
  Directory _directory;

  XFileCachedManager(
    this.name, {
    int maxAgeCachedDays = 365,
    int totalCachedObjects = 500,
    FileFetcher fileFetcher,
  }) : super(
          name,
          maxAgeCacheObject: Duration(days: maxAgeCachedDays),
          maxNrOfCacheObjects: totalCachedObjects,
          fileFetcher: fileFetcher,
        );

  @override
  Future<String> getFilePath() async {
    if (_directory == null) _directory = await getTemporaryDirectory();
    return path.join(_directory.path, name);
  }
}
