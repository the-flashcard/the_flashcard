import 'package:tf_core/tf_core.dart';

abstract class DeckRepository {
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

  Future<String> addCard(String deckId, int cardVersion, CardDesign design);

  Future<List<String>> addCards(
      String deckId, int cardVersion, List<CardDesign> designs);

  Future<String> addCardToNewsDeck(int cardVersion, CardDesign design);

  Future<List<DeckCategory>> getDeckCategories();

  Future<Deck> getDeck(String deckId);

  Future<Map<String, Deck>> getDecks(List<String> deckIds);

  Future<List<Deck>> getNewDecks();

  Future<bool> deleteDeck(String deckId);

  Future<List<String>> deleteDecks(List<String> deckIds);

  Future<bool> publishDeck(String deckId);

  Future<bool> unpublishDeck(String deckId);

  Future<PageResult<Deck>> searchDeck(SearchRequest searchRequest,
      {String query});

  Future<PageResult<Deck>> searchMyDeck(SearchRequest searchRequest);

  Future<Deck> removeCards(String deckId, List<String> cardIds);

  Future<List<Deck>> getTrendingDecks();
}

class DeckRepositoryImpl implements DeckRepository {
  final HttpClient _client;

  DeckRepositoryImpl(this._client);

  @override
  Future<Deck> createDeck(
    String name,
    String desc,
    Container design,
    String thumbnailUrl,
    DeckStatus deckStatus, {
    String categoryId,
  }) async {
    Map<String, dynamic> body = {
      'name': name,
      'description': desc,
      'design': design?.toJson(),
      'thumbnail': thumbnailUrl,
      'deck_status': deckStatus.index,
      'category': categoryId
    };
    Log.info('body::');
    Log.info(body);
    var data = await _client.post("/deck", body);
    return Deck.fromJson(data);
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
    Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (desc != null) body['description'] = desc;
    if (design != null) body['design'] = design.toJson();
    if (thumbnailUrl != null) body['thumbnail'] = thumbnailUrl;
    if (deckStatus != null) body['deck_status'] = deckStatus.index;
    if (categoryId != null) body['category'] = categoryId;
    if (body.isNotEmpty) {
      return _client
          .put('/deck/${Uri.encodeFull(deckId)}', body)
          .then((data) => data as bool);
    } else {
      return Future.value(false);
    }
  }

  @override
  Future<Deck> removeCards(String deckId, List<String> cardIds) {
    Map<String, dynamic> body = {
      'card_ids': cardIds,
    };
    return _client
        .post('/deck/${Uri.encodeFull(deckId)}/remove_cards', body)
        .then((data) => Deck.fromJson(data));
  }

  @override
  Future<String> addCard(String deckId, int cardVersion, CardDesign design) {
    Map<String, dynamic> body = {
      'card_version': cardVersion,
      'design': design.toJson()
    };
    return _client
        .post('/deck/${Uri.encodeFull(deckId)}/card', body)
        .then((data) => data as String);
  }

  @override
  Future<String> addCardToNewsDeck(int cardVersion, CardDesign design) {
    Map<String, dynamic> body = {
      'card_version': cardVersion,
      'design': design.toJson()
    };
    return _client
        .post("/deck/add_news_card", body)
        .then((data) => data as String);
  }

  @override
  Future<List<String>> addCards(
      String deckId, int cardVersion, List<CardDesign> designs) {
    List<Map<String, dynamic>> requests = [];

    designs.forEach((design) {
      final Map<String, dynamic> request = <String, dynamic>{
        'card_version': cardVersion,
        'design': design.toJson(),
      };
      requests.add(request);
    });

    Map<String, dynamic> body = {'cards': requests};

    return _client
        .post('/deck/${Uri.encodeFull(deckId)}/cards', body)
        .then((data) => data.map<String>((x) => x as String).toList());
  }

  @override
  Future<List<DeckCategory>> getDeckCategories() {
    return _client.get('/deck/category/list').then((data) {
      return data.map<DeckCategory>((v) => DeckCategory.fromJson(v)).toList();
    });
  }

  @override
  Future<Deck> getDeck(String deckId) {
    return _client
        .get('/deck/${Uri.encodeFull(deckId)}')
        .then((data) => Deck.fromJson(data));
  }

  @override
  Future<Map<String, Deck>> getDecks(List<String> deckIds) {
    if (deckIds != null && deckIds.isNotEmpty) {
      Map<String, dynamic> body = {'deck_ids': deckIds};
      return _client.post("/deck/list", body).then((data) {
        var r = <String, Deck>{};
        data.forEach((k, v) {
          r[k] = Deck.fromJson(v);
        });
        return r;
      });
    } else {
      return Future.value(<String, Deck>{});
    }
  }

  @override
  Future<List<Deck>> getNewDecks() {
    return _client.get('/deck/list/new').then((data) {
      return data.map<Deck>((v) => Deck.fromJson(v)).toList();
    });
  }

  @override
  Future<bool> deleteDeck(String deckId) {
    return _client
        .delete("/deck/${Uri.encodeFull(deckId)}/del")
        .then((data) => data as bool);
  }

  @override
  Future<List<String>> deleteDecks(List<String> deckIds) {
    if (deckIds != null && deckIds.isNotEmpty) {
      Map<String, dynamic> body = {'deck_ids': deckIds};
      return _client.post("/deck/multi_del", body).then((data) {
        return data.map<String>((v) => v as String).toList();
      });
    } else
      return Future.value(<String>[]);
  }

  @override
  Future<bool> publishDeck(String deckId) {
    return _client.post("/deck/${Uri.encodeFull(deckId)}/publish",
        <String, dynamic>{}).then((data) => data as bool);
  }

  @override
  Future<bool> unpublishDeck(String deckId) {
    return _client.post("/deck/${Uri.encodeFull(deckId)}/unpublish",
        <String, dynamic>{}).then((data) => data as bool);
  }

  @override
  Future<PageResult<Deck>> searchDeck(SearchRequest searchRequest,
      {String query}) {
    Map<String, dynamic> params = <String, dynamic>{};
    if (query != null && query.isNotEmpty) {
      params["query"] = query;
    }
    return _client
        .post('/deck/search', searchRequest.toJson(), params: params)
        .then((data) {
      var total = data['total'];
      var records =
          List<Deck>.from(data['records'].map((v) => Deck.fromJson(v)));
      return PageResult<Deck>(total, records);
    });
  }

  @override
  Future<PageResult<Deck>> searchMyDeck(SearchRequest searchRequest) {
    return _client.post('/deck/search/me', searchRequest.toJson()).then((data) {
      var total = data['total'];
      var records =
          List<Deck>.from(data['records'].map((v) => Deck.fromJson(v)));
      return PageResult<Deck>(total, records);
    });
  }

  @override
  Future<List<Deck>> getTrendingDecks() {
    return _client.get('/deck/trending').then((data) {
      return data.map<Deck>((v) => Deck.fromJson(v)).toList();
    });
  }
}

class MockDeckRepository implements DeckRepository {
  Deck deck;

  @override
  Future<String> addCard(String deckId, int cardVersion, CardDesign design) {
    return Future.delayed(const Duration(seconds: 3), () => 'fake-card');
  }

  @override
  Future<String> addCardToNewsDeck(int cardVersion, CardDesign design) {
    return Future.delayed(const Duration(seconds: 3), () => 'fake-card');
  }

  @override
  Future<List<String>> addCards(
      String deckId, int cardVersion, List<CardDesign> designs) {
    return Future.delayed(const Duration(seconds: 3), () => ['fake-card']);
  }

  @override
  Future<Deck> createDeck(String name, String desc, Container design,
      String thumbnailUrl, DeckStatus deckStatus,
      {String categoryId}) {
    deck = Deck()
      ..name = name
      ..description = desc
      ..design = design
      ..thumbnail = thumbnailUrl
      ..deckStatus = deckStatus;
    return Future.delayed(const Duration(seconds: 3), () => deck);
  }

  @override
  Future<bool> deleteDeck(String deckId) {
    deck = null;
    return Future.delayed(const Duration(seconds: 3), () => true);
  }

  @override
  Future<List<String>> deleteDecks(List<String> deckIds) {
    return Future.delayed(const Duration(seconds: 3), () => []);
  }

  @override
  Future<bool> editDeck(String deckId,
      {String name,
      String desc,
      Container design,
      String thumbnailUrl,
      DeckStatus deckStatus,
      String categoryId}) {
    deck.updateWith(
      name: name,
      description: desc,
      design: design,
      thumbnail: thumbnailUrl,
      deckStatus: deckStatus,
    );
    return Future.delayed(const Duration(seconds: 3), () => true);
  }

  @override
  Future<Deck> getDeck(String deckId) {
    return Future.delayed(const Duration(seconds: 3), () => deck);
  }

  @override
  Future<List<DeckCategory>> getDeckCategories() {
    return Future.delayed(const Duration(seconds: 3), () => []);
  }

  @override
  Future<Map<String, Deck>> getDecks(List<String> deckIds) {
    return Future.delayed(const Duration(seconds: 3), () => {});
  }

  @override
  Future<List<Deck>> getNewDecks() {
    return Future.delayed(const Duration(seconds: 3), () => []);
  }

  @override
  Future<List<Deck>> getTrendingDecks() {
    return Future.delayed(const Duration(seconds: 3), () => []);
  }

  @override
  Future<bool> publishDeck(String deckId) {
    deck.updateWith(deckStatus: DeckStatus.Published);
    return Future.delayed(const Duration(seconds: 3), () => true);
  }

  @override
  Future<Deck> removeCards(String deckId, List<String> cardIds) {
    deck.cardIds.removeWhere((cardId) => cardIds.contains(cardId));
    return Future.delayed(const Duration(seconds: 3), () => deck);
  }

  @override
  Future<PageResult<Deck>> searchDeck(SearchRequest searchRequest,
      {String query}) {
    return Future.delayed(const Duration(seconds: 3), () => PageResult(0, []));
  }

  @override
  Future<PageResult<Deck>> searchMyDeck(SearchRequest searchRequest) {
    return Future.delayed(const Duration(seconds: 3), () => PageResult(0, []));
  }

  @override
  Future<bool> unpublishDeck(String deckId) {
    deck.updateWith(deckStatus: DeckStatus.Protected);
    return Future.delayed(const Duration(seconds: 3), () => true);
  }
}
