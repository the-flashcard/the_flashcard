import 'package:tf_core/tf_core.dart';

abstract class GenerateCardRepository {
  Future<List<GenerateData>> generateCards(int cardVersion, String sourceLang,
      String targetLang, List<String> words);

  Future<GenerateInfo> generateNewsCard(String sourceLang, String targetLang,
      String word, List<String> examples, String partOfSpeech);
}

class GenerateCardRepositoryImpl implements GenerateCardRepository {
  final HttpClient _client;

  GenerateCardRepositoryImpl(this._client);

  @override
  Future<List<GenerateData>> generateCards(int cardVersion, String sourceLang,
      String targetLang, List<String> words) {
    if (cardVersion != null &&
        sourceLang != null &&
        targetLang != null &&
        words != null &&
        words.isNotEmpty) {
      Map<String, dynamic> body = {
        'card_version': cardVersion,
        'source_lang': sourceLang,
        'target_lang': targetLang,
        'words': words
      };

      return _client.post('/generate/card/multi_vocab', body).then((data) {
        return List<GenerateData>.from(
            data.map((json) => GenerateData.fromJson(json)));
      });
    } else {
      return Future.value(<GenerateData>[]);
    }
  }

  @override
  Future<GenerateInfo> generateNewsCard(String sourceLang, String targetLang,
      String word, List<String> examples, String partOfSpeech) {
    Map<String, dynamic> body = {
      'source_lang': sourceLang,
      'target_lang': targetLang,
      'word': word,
      'examples': examples,
      'part_of_speech': partOfSpeech
    };
    return _client
        .post('/generate/card/news', body)
        .then((json) => GenerateInfo.fromJson(json));
  }
}
