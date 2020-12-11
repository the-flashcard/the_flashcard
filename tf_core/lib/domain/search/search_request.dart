import 'package:tf_core/tf_core.dart';

class SearchRequest {
  final List<TermsQuery> terms = [];
  final List<NotQuery> notTerms = [];
  final List<RangeQuery> ranges = [];
  final List<MatchQuery> matches = [];
  final List<SortQuery> sorts = [];
  int from;
  int size;

  SearchRequest(this.from, this.size);

  SearchRequest.defaultSearchNews()
      : from = 0,
        size = 15 {
    this.addSort(SortQuery('published_time', 'desc'));
  }

  SearchRequest addTermsQuery(TermsQuery query) {
    terms.add(query);
    return this;
  }

  SearchRequest addNotTermsQuery(NotQuery query) {
    notTerms.add(query);
    return this;
  }

  SearchRequest addRangeQuery(RangeQuery query) {
    ranges.add(query);
    return this;
  }

  SearchRequest addMatchQuery(MatchQuery query) {
    matches.add(query);
    return this;
  }

  SearchRequest addSort(SortQuery query) {
    sorts.add(query);
    return this;
  }

  SearchRequest.fromJson(Map<String, dynamic> json) {
    if (json['terms'] != null)
      json['terms'].forEach((v) => terms.add(TermsQuery.fromJson(v)));
    if (json['not_terms'] != null)
      json['not_terms'].forEach((v) => notTerms.add(NotQuery.fromJson(v)));
    if (json['ranges'] != null)
      json['ranges'].forEach((v) => ranges.add(RangeQuery.fromJson(v)));
    if (json['matches'] != null)
      json['matches'].forEach((v) => matches.add(MatchQuery.fromJson(v)));
    if (json['sorts'] != null)
      json['sorts'].forEach((v) => sorts.add(SortQuery.fromJson(v)));
    from = json['from'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['terms'] = this.terms.map((x) => x.toJson()).toList();
    data['not_terms'] = this.notTerms.map((x) => x.toJson()).toList();
    data['ranges'] = this.ranges.map((x) => x.toJson()).toList();
    data['matches'] = this.matches.map((x) => x.toJson()).toList();
    data['sorts'] = this.sorts.map((x) => x.toJson()).toList();
    data['from'] = this.from;
    data['size'] = this.size;
    return data;
  }
}
