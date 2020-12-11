import 'package:meta/meta.dart';
import 'package:tf_core/tf_core.dart';

@immutable
abstract class XDictService {
  Future<List<WordSuggestion>> suggest(String query);

  Future<DictionaryRecord> lookup(String word, {String targetLang = 'en'});
}

class XDictServiceImpl extends XDictService {
  final XDictRepository _repository;

  XDictServiceImpl(this._repository);

  @override
  Future<DictionaryRecord> lookup(String word, {String targetLang = 'en'}) {
    return _repository.lookup(word, targetLang);
  }

  @override
  Future<List<WordSuggestion>> suggest(String query) {
    return _repository.suggest(query);
  }
}
