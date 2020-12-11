import 'package:tf_core/tf_core.dart';

class Card {
  String id;
  String deckId;
  String username;
  int cardVersion;
  CardDesign design;
  int updatedTime;
  int createdTime;

  Card() {
    design = CardDesign();
  }

  Card.from(Card card) {
    this.id = card.id;
    this.deckId = card.deckId;
    this.username = card.username;
    this.cardVersion = card.cardVersion;
    this.design = CardDesign.from(card.design);
    this.updatedTime = card.updatedTime;
    this.createdTime = card.createdTime;
  }

  Container getThumbnailCardSide() {
    if (design.back != null && design.back.getComponentCount() > 0) {
      return design.back;
    } else {
      return design.getFront(0) ?? Container();
    }
  }

  Card.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deckId = json['deck_id'];
    username = json['username'];
    cardVersion = json['card_version'];
    if (json['design'] != null) design = CardDesign.fromJson(json['design']);
    updatedTime = json['updated_time'];
    createdTime = json['created_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['deck_id'] = this.deckId;
    data['username'] = this.username;
    data['card_version'] = this.cardVersion;
    if (design != null) data['design'] = this.design.toJson();
    data['updated_time'] = this.updatedTime;
    data['created_time'] = this.createdTime;
    return data;
  }
}
