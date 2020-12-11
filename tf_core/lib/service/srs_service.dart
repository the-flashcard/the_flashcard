import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class SRSService {
  Future<ReviewInfo> addCard(String cardId);

  Future<Map<String, ReviewInfo>> addCards(List<String> cardIds);

  Future<ReviewInfo> review(
      String cardId, ReviewAnswer answer, int durationInMs);

  Future<ReviewInfo> ignore(String cardId);

  Future<ReviewInfo> moveDone(String cardId);

  Future<ReviewInfo> learnAgain(String cardId);

  Future<bool> delete(String cardId);

  Future<int> multiDelete(List<String> cardIds);

  Future<PageResult<Deck>> searchDue(SearchRequest searchRequest);

  Future<PageResult<Deck>> searchLearning(SearchRequest searchRequest);

  Future<PageResult<Deck>> searchDone(SearchRequest searchRequest);

  Future<List<ReviewCard>> getReviewCards(List<String> cardIds);

  Future<Map<String, ReviewInfo>> getReviewInfo(List<String> cardIds);
}

class SRSServiceImpl implements SRSService {
  final SRSRepository _repository;
  final CardRepository _cardRepository;

  SRSServiceImpl(this._repository, this._cardRepository);

  @override
  Future<ReviewInfo> addCard(String cardId) {
    return _repository.addCard(cardId);
  }

  @override
  Future<Map<String, ReviewInfo>> addCards(List<String> cardIds) {
    return _repository.addCards(cardIds);
  }

  @override
  Future<ReviewInfo> review(
      String cardId, ReviewAnswer answer, int durationInMs) {
    return _repository.review(cardId, answer, durationInMs);
  }

  @override
  Future<ReviewInfo> ignore(String cardId) {
    return _repository.ignore(cardId);
  }

  @override
  Future<ReviewInfo> moveDone(String cardId) {
    return _repository.moveDone(cardId);
  }

  @override
  Future<ReviewInfo> learnAgain(String cardId) {
    return _repository.learnAgain(cardId);
  }

  @override
  Future<bool> delete(String cardId) {
    return _repository.delete(cardId);
  }

  @override
  Future<int> multiDelete(List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty)
      return _repository.multiDelete(cardIds);
    else
      return Future.value(0);
  }

  @override
  Future<PageResult<Deck>> searchDue(SearchRequest searchRequest) {
    return _repository.searchDueDecks(searchRequest);
  }

  @override
  Future<PageResult<Deck>> searchLearning(SearchRequest searchRequest) {
    return _repository.searchLearningDecks(searchRequest);
  }

  @override
  Future<PageResult<Deck>> searchDone(SearchRequest searchRequest) {
    return _repository.searchDoneDecks(searchRequest);
  }

  @override
  Future<List<ReviewCard>> getReviewCards(List<String> cardIds) {
    return _repository.getReviewCards(cardIds);
  }

  @override
  Future<Map<String, ReviewInfo>> getReviewInfo(List<String> cardIds) {
    return _repository.getReviewInfo(cardIds);
  }
}
