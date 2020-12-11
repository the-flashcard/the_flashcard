import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class CardRepository {
  Future<Card> editCard(String cardId, CardDesign design);

  Future<Card> getCard(String cardId);

  Future<Map<String, Card>> getCards(List<String> cardIds);

  Future<List<ReviewCard>> getReviewCardAsList(List<String> cardIds);

  Future<Map<String, List<ReviewCard>>> getReviewCardAsMap(
      List<String> cardIds);
}

class CardRepositoryImpl implements CardRepository {
  final HttpClient _client;

  CardRepositoryImpl(this._client);

  @override
  Future<Card> editCard(String cardId, CardDesign design) {
    Map<String, dynamic> body = {'design': design.toJson()};
    return _client
        .put("/card/${Uri.encodeFull(cardId)}", body)
        .then((data) => Card.fromJson(data));
  }

  @override
  Future<Card> getCard(String cardId) {
    return _client
        .get("/card/${Uri.encodeFull(cardId)}")
        .then((data) => Card.fromJson(data));
  }

  @override
  Future<Map<String, Card>> getCards(List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      Map<String, dynamic> body = {'card_ids': cardIds};
      return _client.post("/card/list", body).then((data) {
        final cards = <String, Card>{};
        data.forEach((k, v) {
          cards[k] = Card.fromJson(v);
        });
        return cards;
      });
    } else {
      return Future.value(<String, Card>{});
    }
  }

  @override
  Future<List<ReviewCard>> getReviewCardAsList(List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      Map<String, dynamic> body = {'card_ids': cardIds};
      return _client.post("/card/detail/list", body).then((dataList) {
        return dataList
            .map<ReviewCard>((json) => ReviewCard.fromJson(json))
            .toList();
      });
    } else {
      return Future.value(<ReviewCard>[]);
    }
  }

  @override
  Future<Map<String, List<ReviewCard>>> getReviewCardAsMap(
      List<String> cardIds) {
    if (cardIds != null && cardIds.isNotEmpty) {
      Map<String, dynamic> body = {'card_ids': cardIds};
      return _client
          .post("/card/detail/tab", body)
          .then((dataMap) => dataMap.map((k, v) {
                return MapEntry(k, v.map((json) => ReviewCard.fromJson(json)));
              }));
    } else {
      return Future.value(<String, List<ReviewCard>>{});
    }
  }
}
