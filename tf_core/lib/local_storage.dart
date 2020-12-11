import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

abstract class LocalStorage {
  Future<bool> init();

  Future<void> put(String key, dynamic value);

  Future<void> delete(String key);

  Future<dynamic> get(String key);

  Future<int> clear();
}

class HiveStorage extends LocalStorage {
  Box _box;

  @override
  Future<bool> init() async {
    try {
      var _directory = await getTemporaryDirectory();
      Hive.init(_directory.path);
      _box = await Hive.openBox('storageBox');
      return true;
    } catch (ex) {
      print("$runtimeType: ${ex.message}");
      return false;
    }
  }

  @override
  Future<int> clear() {
    return _box.clear();
  }

  @override
  Future<void> delete(String key) {
    return _box.delete(key);
  }

  @override
  Future<dynamic> get(String key) {
    return Future.value(_box.get(key));
  }

  @override
  Future<void> put(String key, dynamic value) {
    return _box.put(key, value);
  }
}
