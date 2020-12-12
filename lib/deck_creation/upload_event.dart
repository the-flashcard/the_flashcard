import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:the_flashcard/deck_creation/audio_creation/audio_editing_screen.dart';

@immutable
abstract class UploadEvent extends Equatable {
  UploadEvent([this.props = const []]);

  @override
  final List<Object> props;
}

class UploadVideoEvent extends UploadEvent {
  final File file;

  UploadVideoEvent(this.file) : super([file]);

  @override
  String toString() => 'UploadVideoEvent';
}

class UploadAudioEvent extends UploadEvent {
  final AudioData audioData;
  final Key key;

  UploadAudioEvent(this.audioData, {this.key}) : super([audioData]);

  @override
  String toString() => 'UploadAudioEvent';
}

class UploadAudioUrlEvent extends UploadEvent {
  final Key key;
  final String url;
  final String text;

  UploadAudioUrlEvent(
    this.url, {
    this.key,
    this.text,
  }) : super([url, key]);

  @override
  String toString() => 'UploadAudioUrl $url';
}

class UploadImageEvent extends UploadEvent {
  final File file;
  final Key key;

  UploadImageEvent(this.file, {this.key}) : super([file]);

  @override
  String toString() => 'UploaImageEvent';
}

class VideoUploadedSuccessEvent extends UploadEvent {
  final String response;

  VideoUploadedSuccessEvent(this.response) : super([response]);

  @override
  String toString() => 'VideoUploadedSuccessEvent';
}

class AudioUploadedSuccessEvent extends UploadEvent {
  final String response;
  final AudioData audioData;
  final Key key;
  final bool passConfiglink;

  AudioUploadedSuccessEvent(this.response, this.audioData,
      {this.key, this.passConfiglink = false})
      : super([response]);

  @override
  String toString() => 'AudioUploadedSuccessEvent';
}

class AudioUrlUploadedSuccessEvent extends UploadEvent {
  final String url;
  final Key key;
  final String text;

  AudioUrlUploadedSuccessEvent(this.url, {this.key, this.text})
      : super([url, key]);

  @override
  String toString() => 'AudioUploadedSuccessEvent';
}

class ImageUploadedSuccessEvent extends UploadEvent {
  final String response;
  final Key key;

  ImageUploadedSuccessEvent(this.response, {this.key}) : super([response]);

  @override
  String toString() => 'ImageUploadedSuccessEvent';
}

class UploadingEvent extends UploadEvent {
  @override
  String toString() => 'UploadingEvent';
}

class ProgressUploadingEvent extends UploadEvent {
  final double percen;
  final Key key;

  ProgressUploadingEvent(this.percen, {this.key}) : super([percen, key]);

  @override
  String toString() => 'ProgressUploadingEvent $percen';
}

class CancelUploadEvent extends UploadEvent {
  @override
  String toString() => 'CancelUploadEvent';
}

class ErrorEvent extends UploadEvent {
  @override
  String toString() => 'ErrorEvent';
}

class UploadErrorEvent extends UploadEvent {
  final String error;

  UploadErrorEvent(this.error);

  @override
  String toString() => 'UploadErrorEvent';
}
