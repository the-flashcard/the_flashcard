enum ReviewAnswer { DontKnow, NotSure, Known }

class ReviewInfo {
  static const String Remain = "remain";
  static const String Learning = "learning";
  static const String Ignored = "ignored";
  static const String Done = "done";

  String id;
  String cardId;
  String deckId;
  String username;
  String status;
  int memorizingLevel;
  int startDate;
  int dueDate;
  int lastReviewTime;
  int updatedTime;
  int createdTime;

  ReviewInfo();

  bool isNotInReview() {
    switch (status) {
      case Learning:
      case Ignored:
      case Done:
        return false;
      default:
        return true;
    }
  }

  int dayLeft() {
    final DateTime t1 =
        DateTime.fromMillisecondsSinceEpoch(dueDate, isUtc: true);
    final DateTime t2 = DateTime.utc(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    Duration delta = t1.difference(t2);

    return delta.inDays;
  }

  ReviewInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cardId = json['card_id'];
    deckId = json['deck_id'];
    username = json['username'];
    status = json['status'];
    memorizingLevel = json['memorizing_level'];
    startDate = json['start_date'];
    dueDate = json['due_date'];
    lastReviewTime = json['last_review_time'];
    updatedTime = json['updated_time'];
    createdTime = json['created_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['card_id'] = this.cardId;
    data['deck_id'] = this.deckId;
    data['username'] = this.username;
    data['status'] = this.status;
    data['memorizing_level'] = this.memorizingLevel;
    data['start_date'] = this.startDate;
    data['due_date'] = this.dueDate;
    data['last_review_time'] = this.lastReviewTime;
    data['updated_time'] = this.updatedTime;
    data['created_time'] = this.createdTime;
    return data;
  }
}
