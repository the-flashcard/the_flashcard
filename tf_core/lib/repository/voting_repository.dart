import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class VotingRepository {
  Future<bool> like(String objectType, String objectId);

  Future<bool> dislike(String objectType, String objectId);

  Future<bool> deleteVote(String objectType, String objectId);

  Future<Map<String, VotingMetric>> getLikeCount(
      String objectType, List<String> objectIds);

  Future<Map<String, VotingInfo>> getLikeStatus(
      String objectType, List<String> objectIds);

  Future<VotingDetail> getVotingDetail(
      String objectType, List<String> objectIds);

  Future<List<VotingMetric>> getTops(String objectType, int size);

  Future<PageResult<VotingInfo>> search(
      String objectType, SearchRequest searchRequest);
}

class VotingRepositoryImpl implements VotingRepository {
  HttpClient _client;

  VotingRepositoryImpl(this._client);

  @override
  Future<bool> like(String objectType, String objectId) {
    return _client.post("/voting/$objectType/${Uri.encodeFull(objectId)}/like",
        <String, dynamic>{}).then((data) => data as bool);
  }

  @override
  Future<bool> dislike(String objectType, String objectId) {
    return _client.post(
        "/voting/$objectType/${Uri.encodeFull(objectId)}/dislike",
        <String, dynamic>{}).then((data) => data as bool);
  }

  @override
  Future<bool> deleteVote(String objectType, String objectId) {
    return _client
        .delete("/voting/$objectType/${Uri.encodeFull(objectId)}")
        .then((data) => data as bool);
  }

  @override
  Future<VotingDetail> getVotingDetail(
      String objectType, List<String> objectIds) {
    Map<String, dynamic> body = {'object_ids': objectIds};
    return _client
        .post("/voting/$objectType/stats", body)
        .then((data) => VotingDetail.fromJson(data));
  }

  @override
  Future<Map<String, VotingMetric>> getLikeCount(
      String objectType, List<String> objectIds) {
    Map<String, dynamic> body = {'object_ids': objectIds};
    return _client.post("/voting/$objectType/like/list", body).then((data) {
      return data.map((k, v) => MapEntry(k, VotingMetric.fromJson(v)));
    });
  }

  @override
  Future<Map<String, VotingInfo>> getLikeStatus(
      String objectType, List<String> objectIds) {
    Map<String, dynamic> body = {'object_ids': objectIds};
    return _client.post("/voting/$objectType/like/status", body).then((data) {
      return data.map((k, v) => MapEntry(k, VotingInfo.fromJson(v)));
    });
  }

  @override
  Future<List<VotingMetric>> getTops(String objectType, int size) {
    Map<String, dynamic> params = {'size': size.toString()};
    return _client
        .get("/voting/$objectType/trending", params: params)
        .then((data) {
      return data.map<VotingMetric>((v) => VotingMetric.fromJson(v)).toList();
    });
  }

  @override
  Future<PageResult<VotingInfo>> search(
      String objectType, SearchRequest searchRequest) {
    return _client
        .post('/voting/$objectType/search', searchRequest.toJson())
        .then((data) {
      var total = data['total'];
      var records = data['records']
          .map<VotingInfo>((v) => VotingInfo.fromJson(v))
          .toList();
      return PageResult<VotingInfo>(total, records);
    });
  }
}
