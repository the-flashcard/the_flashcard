import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tf_core/tf_core.dart';

@immutable
abstract class UploadState extends Equatable {
  UploadState([this.props = const []]);

  @override
  final List<Object> props;

  @override
  String toString() => 'UploadState';

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;
}

class InitState extends UploadState {
  @override
  String toString() => 'InitState';
}

class CompleteState extends UploadState {
  @override
  String toString() => 'CompleteState';
}

class UploadingState extends UploadState {
  final Key key;
  final double percen;

  UploadingState({this.key, this.percen = 0});

  @override
  String toString() => 'UploadingState';
}

class CancelUploading extends UploadState {
  final Key key;

  CancelUploading({this.key});

  @override
  String toString() => 'CancelUploading';
}

class UploadFailed extends UploadState {
  final String messenge;

  UploadFailed(this.messenge) : super([messenge]);

  @override
  String toString() => 'UploadFailed $messenge';

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;
}

class VideoUploadedSuccess extends UploadState {
  final Video component;

  VideoUploadedSuccess(this.component) : super([component]);

  @override
  String toString() => 'VideoUploadedSuccess';
}

class AudioUploadedSuccess extends UploadState {
  final Audio component;
  final Key key;

  AudioUploadedSuccess(this.component, {this.key}) : super([component]);

  @override
  String toString() => 'AudioUploadedSuccess';
}

class AudioUrlUploadedSuccess extends UploadState {
  final String url;
  final Key key;
  final String text;

  AudioUrlUploadedSuccess(this.url, {this.key, this.text}) : super([url, key]);

  @override
  String toString() => 'AudioUploadedSuccess $url';
}

class ImageUploadedSuccess extends UploadState {
  final Image component;
  final Key key;

  ImageUploadedSuccess(this.component, {this.key}) : super([component]);

  @override
  String toString() => 'AddImageSuccess';
}

class ImageUploading extends UploadState {
  @override
  String toString() => 'ImageUploading';
}
