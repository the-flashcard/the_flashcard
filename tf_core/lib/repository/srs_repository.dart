import 'package:tf_core/tf_core.dart';

abstract class SRSRepository {
  Future<ReviewInfo> addCard(String cardId);

  Future<Map<String, ReviewInfo>> addCards(List<String> cardIds);

  Future<ReviewInfo> review(
      String cardId, ReviewAnswer answer, int durationInMs);

  Future<ReviewInfo> ignore(String cardId);

  Future<ReviewInfo> moveDone(String cardId);

  Future<ReviewInfo> learnAgain(String cardId);

  Future<bool> delete(String cardId);

  Future<int> multiDelete(List<String> cardIds);

  Future<PageResult<Deck>> searchDueDecks(SearchRequest searchRequest);

  Future<PageResult<Deck>> searchLearningDecks(SearchRequest searchRequest);

  Future<PageResult<Deck>> searchDoneDecks(SearchRequest searchRequest);

  Future<List<ReviewCard>> getReviewCards(List<String> cardIds);

  Future<Map<String, ReviewInfo>> getReviewInfo(List<String> cardIds);
}

class SRSRepositoryImpl implements SRSRepository {
  final HttpClient _client;

  SRSRepositoryImpl(this._client);

  @override
  Future<ReviewInfo> addCard(String cardId) {
    return _client.post("/srs/card/${Uri.encodeFull(cardId)}",
        <String, dynamic>{}).then((data) => ReviewInfo.fromJson(data));
  }

  @override
  Future<Map<String, ReviewInfo>> addCards(List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      Map<String, dynamic> body = {'card_ids': cardIds};
      return _client.post("/srs/card", body).then((data) {
        final r = <String, ReviewInfo>{};
        data.forEach((k, v) => r[k] = ReviewInfo.fromJson(v));
        return r;
      });
    } else {
      return Future.value(<String, ReviewInfo>{});
    }
  }

  @override
  Future<ReviewInfo> review(
      String cardId, ReviewAnswer answer, int durationInMs) {
    Map<String, dynamic> body = {
      'answer': answer.index,
      'duration': durationInMs
    };
    return _client
        .post("/srs/card/${Uri.encodeFull(cardId)}/review", body)
        .then((data) => ReviewInfo.fromJson(data));
  }

  @override
  Future<ReviewInfo> moveDone(String cardId) {
    return _client.post("/srs/card/${Uri.encodeFull(cardId)}/move_done",
        <String, dynamic>{}).then((data) => ReviewInfo.fromJson(data));
  }

  @override
  Future<ReviewInfo> ignore(String cardId) {
    return _client.post("/srs/card/${Uri.encodeFull(cardId)}/ignore",
        <String, dynamic>{}).then((data) => ReviewInfo.fromJson(data));
  }

  @override
  Future<ReviewInfo> learnAgain(String cardId) {
    return _client.post("/srs/card/${Uri.encodeFull(cardId)}/learn_again",
        <String, dynamic>{}).then((data) => ReviewInfo.fromJson(data));
  }

  @override
  Future<bool> delete(String cardId) {
    return _client
        .delete("/srs/card/${Uri.encodeFull(cardId)}")
        .then((data) => data as bool);
  }

  @override
  Future<int> multiDelete(List<String> cardIds) {
    Map<String, dynamic> body = {'card_ids': cardIds};
    return _client
        .post("/srs/card/list/delete", body)
        .then((data) => data as int);
  }

//  @override
//  Future<PageResult<ReviewInfo>> searchDue(SearchRequest searchRequest) {
//    return  _client.post('/srs/card/search/due', searchRequest.toJson()).then((data) {
//      var total = data['total'];
//      var records = List<ReviewInfo>.from(
//          data['records'].map((v) => ReviewInfo.fromJson(v)));
//      return PageResult<ReviewInfo>(total, records);
//    });
//  }
//
//  @override
//  Future<PageResult<ReviewInfo>> searchLearning(SearchRequest searchRequest) {
//    return  _client.post('/srs/card/search/learning', searchRequest.toJson()).then((data) {
//      var total = data['total'];
//      var records = List<ReviewInfo>.from(
//          data['records'].map((v) => ReviewInfo.fromJson(v)));
//      return PageResult<ReviewInfo>(total, records);
//    });
//  }
//
//  @override
//  Future<PageResult<ReviewInfo>> searchDone(SearchRequest searchRequest) {
//    return  _client.post('/srs/card/search/done', searchRequest.toJson()).then((data) {
//      var total = data['total'];
//      var records = List<ReviewInfo>.from(
//          data['records'].map((v) => ReviewInfo.fromJson(v)));
//      return PageResult<ReviewInfo>(total, records);
//    });
//  }
//
//  @override
//  Future<PageResult<ReviewInfo>> search(SearchRequest searchRequest) {
//    return  _client.post('/srs/card/search', searchRequest.toJson()).then((data) {
//      var total = data['total'];
//      var records = List<ReviewInfo>.from(
//          data['records'].map((v) => ReviewInfo.fromJson(v)));
//      return PageResult<ReviewInfo>(total, records);
//    });
//  }

  @override
  Future<PageResult<Deck>> searchDueDecks(SearchRequest searchRequest) {
    return _client
        .post('/srs/search/deck/due', searchRequest.toJson())
        .then((data) {
      var total = data['total'];
      var records = data['records'].map<Deck>((v) => Deck.fromJson(v)).toList();
      return PageResult<Deck>(total, records);
    });
  }

  @override
  Future<PageResult<Deck>> searchLearningDecks(SearchRequest searchRequest) {
    return _client
        .post('/srs/search/deck/learning', searchRequest.toJson())
        .then((data) {
      var total = data['total'];
      var records = data['records'].map<Deck>((v) => Deck.fromJson(v)).toList();
      return PageResult<Deck>(total, records);
    });
  }

  @override
  Future<PageResult<Deck>> searchDoneDecks(SearchRequest searchRequest) {
    return _client
        .post('/srs/search/deck/done', searchRequest.toJson())
        .then((data) {
      var total = data['total'];
      var records = data['records'].map<Deck>((v) => Deck.fromJson(v)).toList();
      return PageResult<Deck>(total, records);
    });
  }

  @override
  Future<Map<String, ReviewInfo>> getReviewInfo(List<String> cardIds) {
    Map<String, dynamic> body = {
      'card_ids': cardIds,
    };
    if (cardIds != null && cardIds.isNotEmpty) {
      return _client.post("/srs/list", body).then((data) {
        var r = <String, ReviewInfo>{};
        data.forEach((k, v) {
          r[k] = ReviewInfo.fromJson(v);
        });
        return r;
      });
    } else {
      return Future.value(<String, ReviewInfo>{});
    }
  }

  @override
  Future<List<ReviewCard>> getReviewCards(List<String> cardIds) {
    Map<String, dynamic> body = {
      'card_ids': cardIds,
    };
    if (cardIds != null && cardIds.isNotEmpty) {
      return _client.post("/srs/card/list", body).then((data) {
        return data.map<ReviewCard>((x) => ReviewCard.fromJson(x)).toList();
      });
    } else {
      return Future.value(<ReviewCard>[]);
    }
  }
}
