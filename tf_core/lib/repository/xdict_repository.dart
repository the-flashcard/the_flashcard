import 'package:tf_core/tf_core.dart';

abstract class XDictRepository {
  Future<List<WordSuggestion>> suggest(String query);

  Future<DictionaryRecord> lookup(String word, String targetLang);
}

class XDictRepositoryImpl extends XDictRepository {
  final HttpClient _client;

  XDictRepositoryImpl(this._client);

  @override
  Future<DictionaryRecord> lookup(String word, String targetLang) {
    final Map<String, dynamic> lookupParams =
        _getLookupParams(word, targetLang);
    return _client
        .get('/dictionary/lookup', params: lookupParams)
        .then<DictionaryRecord>((json) => DictionaryRecord.fromJson(json));
  }

  Map<String, dynamic> _getLookupParams(String word, String targetLang) {
    final Map<String, dynamic> lookupParams = {
      "source_lang": "en",
      "target_lang": targetLang ?? "en",
      "word": word
    };
    return lookupParams;
  }

  @override
  Future<List<WordSuggestion>> suggest(String query) {
    final Map<String, dynamic> suggestParams = _getSuggestParams(query);
    return _client
        .post('/dictionary/suggest', {}, params: suggestParams)
        .then<List<WordSuggestion>>((wordSuggestions) => wordSuggestions
            .map<WordSuggestion>((json) => WordSuggestion.fromJson(json))
            .toList());
  }

  Map<String, dynamic> _getSuggestParams(String query) {
    final Map<String, String> suggestParams = {
      "languages": "en",
      "size": "15",
      "query": query
    };
    return suggestParams;
  }
}
