import 'dart:async';

import 'package:tf_core/tf_core.dart';

abstract class VotingService {
  static const String ObjectDeck = "deck";

  Future<bool> like(String objectType, String objectId);

  Future<bool> dislike(String objectType, String objectId);

  Future<bool> deleteVote(String objectType, String objectId);

  Future<VotingDetail> getVotingDetail(
      String objectType, List<String> objectIds);

  Future<Map<String, VotingMetric>> getLikeCount(
      String objectType, List<String> objectIds);

  Future<Map<String, VotingInfo>> getLikeStatus(
      String objectType, List<String> objectIds);

  Future<List<VotingMetric>> getTops(String objectType, int size);

  Future<PageResult<VotingInfo>> search(
      String objectType, SearchRequest searchRequest);
}

class VotingServiceImpl extends VotingService {
  VotingRepository _repository;

  VotingServiceImpl(this._repository);

  @override
  Future<bool> like(String objectType, String objectId) {
    return _repository.like(objectType, objectId);
  }

  @override
  Future<bool> dislike(String objectType, String objectId) {
    return _repository.dislike(objectType, objectId);
  }

  @override
  Future<bool> deleteVote(String objectType, String objectId) {
    return _repository.deleteVote(objectType, objectId);
  }

  @override
  Future<VotingDetail> getVotingDetail(
      String objectType, List<String> objectIds) {
    return _repository.getVotingDetail(objectType, objectIds);
  }

  @override
  Future<Map<String, VotingMetric>> getLikeCount(
      String objectType, List<String> objectIds) {
    return _repository.getLikeCount(objectType, objectIds);
  }

  @override
  Future<Map<String, VotingInfo>> getLikeStatus(
      String objectType, List<String> objectIds) {
    return _repository.getLikeStatus(objectType, objectIds);
  }

  @override
  Future<List<VotingMetric>> getTops(String objectType, int size) {
    return _repository.getTops(objectType, size);
  }

  @override
  Future<PageResult<VotingInfo>> search(
      String objectType, SearchRequest searchRequest) {
    return _repository.search(objectType, searchRequest);
  }
}
