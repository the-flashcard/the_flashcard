import 'package:tf_core/tf_core.dart';

export './card.dart';
export './component/component.dart';
export './generate_data.dart';
export './generate_info.dart';
export './review_card.dart';
export './review_info.dart';

class CardVersion {
  static const int V1000 = 1000;
  static const int V2000 = 2000;
}

class DeckCategory {
  String id;
  String name;

  DeckCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

enum DeckStatus { Protected, Published, Deleted }

class Deck {
  String id;
  String username;
  String thumbnail;
  String name;
  String description;
  String categoryId;
  Container design;
  final List<String> cardIds = [];
  DeckStatus deckStatus;
  int updatedTime;
  int createdTime;
  ShortUserProfile ownerDetail;

  int totalLikes = 0;
  int totalDislikes = 0;
  int totalDueCards = 0;
  int weeklyTotalLike = 0;

  VoteStatus voteStatus = VoteStatus.None;

  Deck();

  Deck.from(Deck deck) {
    this.id = deck.id;
    this.username = deck.username;
    this.thumbnail = deck.thumbnail;
    this.name = deck.name;
    this.description = deck.description;
    this.design = deck.design;
    this.categoryId = deck.categoryId;
    deck.cardIds.forEach((cardId) {
      this.cardIds.add(cardId);
    });
    this.deckStatus = deck.deckStatus;
    this.updatedTime = deck.updatedTime;
    this.createdTime = deck.createdTime;
    this.ownerDetail = deck.ownerDetail;
    this.totalLikes = deck.totalLikes;
    this.totalDislikes = deck.totalDislikes;
    this.totalDueCards = deck.totalDueCards;
    this.voteStatus = deck.voteStatus;
  }

  Deck updateWith({
    String thumbnail,
    String name,
    String description,
    Container design,
    DeckStatus deckStatus,
    VoteStatus voteStatus,
    String categoryId,
  }) {
    this.thumbnail = thumbnail ?? this.thumbnail;
    this.name = name ?? this.name;
    this.design = design ?? this.design;
    this.description = description ?? this.description;
    this.deckStatus = deckStatus ?? this.deckStatus;
    this.voteStatus = voteStatus ?? this.voteStatus;
    this.categoryId = categoryId ?? this.categoryId;
    return this;
  }

  bool get hasThumbnail => thumbnail != null && thumbnail.isNotEmpty;

  Deck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    thumbnail = UrlUtils.resolveUploadUrl(json['thumbnail']);
    name = json['name'];
    description = json['description'];
    if (json['design'] != null) design = Container.fromJson(json['design']);
    if (json['cards'] != null) {
      json['cards'].forEach((cardId) => cardIds.add(cardId));
    }
    if (json['deck_status'] != null) {
      var status = json['deck_status'] as int;
      var list = DeckStatus.values.where((x) => x.index == status);
      deckStatus = list.isNotEmpty ? list.first : DeckStatus.Protected;
    } else {
      deckStatus = DeckStatus.Protected;
    }
    updatedTime = json['updated_time'];
    createdTime = json['created_time'];
    categoryId = json['category'];
    if (json['owner_detail'] != null) {
      ownerDetail = ShortUserProfile.fromJson(json['owner_detail']);
    }
    totalLikes = json['total_likes'] ?? 0;
    weeklyTotalLike = json['weekly_total_likes'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['thumbnail'] = this.thumbnail;
    data['name'] = this.name;
    data['design'] = this.design?.toJson();
    data['desctiption'] = this.description;
    data['cards'] = this.cardIds;
    data['deck_status'] = this.deckStatus?.index ?? DeckStatus.Protected.index;
    data['updated_time'] = this.updatedTime;
    data['created_time'] = this.createdTime;
    data['category'] = this.categoryId;
    data['total_likes'] = this.totalLikes;
    data['weekly_total_likes'] = this.weeklyTotalLike;
    if (ownerDetail != null) data['owner_detail'] = this.ownerDetail.toJson();
    return data;
  }

  void addCardIds(List<String> cardIds) {
    if (cardIds != null) {
      cardIds.forEach((id) {
        if (!this.cardIds.contains(id)) this.cardIds.add(id);
      });
    }
  }

  void setCardIds(List<String> cardIds) {
    this.cardIds.clear();
    if (cardIds != null) {
      this.cardIds.addAll(cardIds);
    }
  }
}
