import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class DeckService {
  Future<String> addCard(String deckId, int cardVersion, CardDesign design);

  Future<List<String>> addCards(
      String deckId, int cardVersion, List<CardDesign> designs);

  Future<List<GenerateWordInfo>> generateCards(int cardVersion,
      String sourceLang, String targetLang, List<String> words);

  Future<Card> editCard(String cardId, CardDesign design);

  Future<Card> getCard(String cardId);

  Future<Map<String, Card>> getCards(List<String> cardIds);

  Future<List<ReviewCard>> getReviewCardAsList(List<String> cardIds);

  Future<Map<String, List<ReviewCard>>> getReviewCardAsMap(
      List<String> cardIds);

  Future<Deck> createDeck(
    String name,
    String desc,
    Container design,
    String thumbnailUrl,
    DeckStatus deckStatus, {
    String categoryId,
  });

  Future<bool> editDeck(
    String deckId, {
    String name,
    String desc,
    Container design,
    String thumbnailUrl,
    DeckStatus deckStatus,
    String categoryId,
  });

  Future<List<DeckCategory>> getDeckCategories();

  Future<Deck> getDeck(String deckId);

  Future<Map<String, Deck>> getDecks(List<String> deckIds);

  Future<List<Deck>> getNewDecks();

  Future<bool> deleteDeck(String deckId);

  Future<List<String>> deleteDecks(List<String> deckIds);

  Future<bool> publishDeck(String deckId);

  Future<bool> unPublishDeck(String deckId);

  Future<List<Deck>> getTrendingDecks(int size);

  Future<PageResult<Deck>> searchGlobalDeck(SearchRequest searchRequest,
      {String query});

  Future<PageResult<Deck>> searchMyDeck(SearchRequest searchRequest);

  Future<PageResult<Deck>> searchFavoriteDeck(int from, int size);

  Future<Deck> removeCards(String deckId, List<String> cardIds);

  Future<String> addCardToNewsDeck(int cardVersion, CardDesign design);

  Future<GenerateInfo> generateNewsCard(String sourceLang, String targetLang,
      String word, List<String> examples, String partOfSpeech);
}

class DeckServiceImpl implements DeckService {
  DeckRepository _repository;
  CardRepository _cardRepository;
  VotingService _votingService;
  GenerateCardRepository _generateCardRepository;

  DeckServiceImpl(this._repository, this._cardRepository,
      this._generateCardRepository, this._votingService);

  @override
  Future<Deck> createDeck(
    String name,
    String desc,
    Container design,
    String thumbnailUrl,
    DeckStatus deckStatus, {
    String categoryId,
  }) {
    return _repository.createDeck(name, desc, design, thumbnailUrl, deckStatus,
        categoryId: categoryId);
  }

  @override
  Future<bool> editDeck(
    String deckId, {
    String name,
    String desc,
    Container design,
    String thumbnailUrl,
    DeckStatus deckStatus,
    String categoryId,
  }) {
    return _repository.editDeck(
      deckId,
      name: name,
      desc: desc,
      design: design,
      thumbnailUrl: thumbnailUrl,
      deckStatus: deckStatus,
      categoryId: categoryId,
    );
  }

  @override
  Future<String> addCard(String deckId, int cardVersion, CardDesign design) {
    return _repository.addCard(deckId, cardVersion, design);
  }

  @override
  Future<List<String>> addCards(
      String deckId, int cardVersion, List<CardDesign> designs) {
    return _repository.addCards(deckId, cardVersion, designs);
  }

  @override
  Future<List<GenerateWordInfo>> generateCards(int cardVersion,
      String sourceLang, String targetLang, List<String> words) async {
    return await _generateCardRepository
        .generateCards(cardVersion, sourceLang, targetLang, words)
        .then((result) {
      List<GenerateWordInfo> r = [];

      result.forEach((data) {
        r.add(data.asGenerateWordInfo());
        words.remove(data.word);
      });

      if (words.isNotEmpty) {
        words.forEach((word) {
          r.add(GenerateWordInfo.def(word));
        });
      }
      return r;
    });
  }

  @override
  Future<Card> editCard(String cardId, CardDesign design) {
    return _cardRepository.editCard(cardId, design);
  }

  @override
  Future<Card> getCard(String cardId) {
    return _cardRepository.getCard(cardId);
  }

  @override
  Future<Map<String, Card>> getCards(List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      return _cardRepository.getCards(cardIds);
    } else {
      return Future.value(<String, Card>{});
    }
  }

  @override
  Future<List<ReviewCard>> getReviewCardAsList(List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      return _cardRepository.getReviewCardAsList(cardIds);
    } else {
      return Future.value(<ReviewCard>[]);
    }
  }

  @override
  Future<Map<String, List<ReviewCard>>> getReviewCardAsMap(
      List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      return _cardRepository.getReviewCardAsMap(cardIds);
    } else {
      return Future.value(<String, List<ReviewCard>>{});
    }
  }

  @override
  Future<Deck> getDeck(String deckId) {
    return _repository.getDeck(deckId);
  }

  @override
  Future<Map<String, Deck>> getDecks(List<String> deckIds) {
    return _repository.getDecks(deckIds);
  }

  @override
  Future<bool> publishDeck(String deckId) {
    return _repository.publishDeck(deckId);
  }

  @override
  Future<bool> unPublishDeck(String deckId) {
    return _repository.unpublishDeck(deckId);
  }

  @override
  Future<bool> deleteDeck(String deckId) {
    return _repository.deleteDeck(deckId);
  }

  @override
  Future<List<String>> deleteDecks(List<String> deckIds) {
    return _repository.deleteDecks(deckIds);
  }

  @override
  Future<List<Deck>> getTrendingDecks(int size) async {
    List<Deck> trendingDecks = await _repository.getTrendingDecks();
    await _getVoteDetail(trendingDecks);
    return trendingDecks;
  }

  @override
  Future<List<Deck>> getNewDecks() {
    return _repository.getNewDecks().then((decks) => _getVoteDetail(decks));
  }

  @override
  Future<PageResult<Deck>> searchGlobalDeck(SearchRequest searchRequest,
      {String query}) async {
    PageResult<Deck> result =
        await _repository.searchDeck(searchRequest, query: query);
    await _getVoteDetail(result.records);
    return result;
  }

  @override
  Future<PageResult<Deck>> searchMyDeck(SearchRequest searchRequest) async {
    PageResult<Deck> result = await _repository.searchMyDeck(searchRequest);
    await _getVoteDetail(result.records);
    return result;
  }

  @override
  Future<PageResult<Deck>> searchFavoriteDeck(int from, int size) async {
    SearchRequest searchRequest = SearchRequest(from, size);

    PageResult<VotingInfo> votingResult =
        await _votingService.search(VotingService.ObjectDeck, searchRequest);

    List<String> deckIds =
        votingResult.records.map<String>((x) => x.objectId).toList();
    Map<String, Deck> deckMap = await _repository.getDecks(deckIds);
    List<Deck> decks = deckIds
        .where((id) => deckMap.containsKey(id))
        .map<Deck>((id) => deckMap[id])
        .toList();

    var result = PageResult(votingResult.total, decks);
    await _getVoteDetail(result.records);
    return result;
  }

  Future<List<Deck>> _getVoteDetail(List<Deck> decks) {
    if (decks != null && decks.isNotEmpty) {
      List<String> deckIds = List<String>.from(decks.map((deck) => deck.id));
      return _votingService
          .getVotingDetail(VotingService.ObjectDeck, deckIds)
          .then((votingDetail) {
        decks.forEach((deck) {
          var voteMap = votingDetail.votes;
          var voteStats = votingDetail.statistics;
          if (voteMap != null) {
            deck.voteStatus = voteMap.containsKey(deck.id)
                ? voteMap[deck.id]
                : VoteStatus.None;
          }
          if (voteStats != null) {
            VotingMetric metric = voteStats[deck.id];
            deck.totalLikes = metric != null ? metric.likes : 0;
            deck.totalDislikes = metric != null ? metric.dislikes : 0;
          }
        });
        return decks;
      }, onError: (e) {
        Log.error(
            'Can\'t get the voting stats of these decks:${decks.toString()} \n${e.toString()}');
        return;
      });
    } else {
      return Future.value(decks);
    }
  }

  @override
  Future<List<DeckCategory>> getDeckCategories() {
    return _repository.getDeckCategories();
  }

  @override
  Future<Deck> removeCards(String deckId, List<String> cardIds) {
    return _repository.removeCards(deckId, cardIds);
  }

  @override
  Future<String> addCardToNewsDeck(int cardVersion, CardDesign design) {
    return _repository.addCardToNewsDeck(cardVersion, design);
  }

  @override
  Future<GenerateInfo> generateNewsCard(String sourceLang, String targetLang,
      String word, List<String> examples, String partOfSpeech) {
    return _generateCardRepository.generateNewsCard(
        sourceLang, targetLang, word, examples, partOfSpeech);
  }
}
