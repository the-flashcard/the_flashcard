import 'package:tf_core/tf_core.dart';

class ReviewCard {
  String cardId;
  Card card;
  ReviewInfo reviewInfo;

  ReviewCard(this.cardId, this.card, this.reviewInfo);

  ReviewCard.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    card = json['card'] != null ? Card.fromJson(json['card']) : null;
    reviewInfo =
        json['model'] != null ? ReviewInfo.fromJson(json['model']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['card_id'] = this.cardId;
    data['card'] = card != null ? this.card.toJson() : null;
    data['model'] = reviewInfo != null ? this.reviewInfo.toJson() : null;
    return data;
  }
}
