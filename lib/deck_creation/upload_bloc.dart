import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ddi/di.dart';
import 'package:tf_core/tf_core.dart';
import 'package:the_flashcard/deck_creation/deck_creation.dart';
import 'package:the_flashcard/deck_creation/upload_event.dart';
import 'package:the_flashcard/deck_creation/upload_state.dart';

enum _TypeFile {
  Image,
  Video,
  Audio,
}

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadService uploadService = DI.get(UploadService);

  final int videoMaxSize = Config.getUploadVideoMaxSize();
  final int imageMaxSize = Config.getUploadImageMaxSize();
  final int audioMaxSize = Config.getUploadAudioMaxSize();

  final String staticHost = Config.getStaticHost();

  @override
  UploadState get initialState => InitState();

  @override
  Stream<UploadState> mapEventToState(UploadEvent event) async* {
    switch (event.runtimeType) {
      case UploadVideoEvent:
        yield UploadingState();
        yield* _uploadVideo(event);
        break;
      case UploadAudioEvent:
        yield UploadingState(key: (event as UploadAudioEvent).key);
        yield* _uploadAudio(event);
        break;
      case UploadAudioUrlEvent:
        yield UploadingState(key: (event as UploadAudioUrlEvent).key);
        yield* _uploadAudioUrl(event);
        break;
      case VideoUploadedSuccessEvent:
        yield* _uploadVideoSuccess(event);
        break;
      case AudioUploadedSuccessEvent:
        yield* _uploadAudioSuccess(event);
        break;
      case UploadImageEvent:
        yield UploadingState(key: (event as UploadImageEvent).key);
        yield* _uploadImage(event);
        break;
      case ImageUploadedSuccessEvent:
        yield* _uploadImageSuccess(event);
        break;
      case ErrorEvent:
        yield* _getErrorState();
        break;
      case UploadErrorEvent:
        yield* _getErrorState(error: (event as UploadErrorEvent).error);
        break;
      case UploadingEvent:
        yield ImageUploading();
        break;
      case CancelUploadEvent:
        yield CancelUploading();
        break;
      case ProgressUploadingEvent:
        final progressEvent = event as ProgressUploadingEvent;
        yield UploadingState(
          key: progressEvent.key,
          percen: progressEvent.percen,
        );
        break;
      case AudioUrlUploadedSuccessEvent:
        yield* _audioUrlUploadedSuccess(event);
        break;
      default:
        yield CompleteState();
    }
  }

  //--------------------------------------------------------------------
  Stream<UploadState> _uploadImage(UploadImageEvent event) async* {
    if (validateFile(event.file, _TypeFile.Image)) {
      uploadService
          .uploadFromFile(event.file.path, progressCallback: _progressCallBack)
          .then<void>((url) => onUploadedImage(url, event))
          .catchError((ex) => {Log.error(ex), _dispatchError()});
    } else
      yield* _getErrorState(error: Config.getString("msg_upload_exceed_audio"));
  }

  //--------------------------------------------------------------------
  Stream<UploadState> _uploadVideo(UploadVideoEvent event) async* {
    if (validateFile(event.file, _TypeFile.Video)) {
      uploadService
          .uploadFromFile(event.file.path, progressCallback: _progressCallBack)
          .then<void>(_onUploadedVideo)
          .catchError((ex) => {Log.error(ex), _dispatchError()});
    } else
      yield* _getErrorState(error: Config.getString("msg_upload_exceed_video"));
  }

  //--------------------------------------------------------------------
  Stream<UploadState> _uploadAudio(UploadAudioEvent event) async* {
    if (event.audioData != null &&
        validateFile(event.audioData.file, _TypeFile.Audio)) {
      uploadService
          .uploadFromFile(event.audioData.file.path,
              progressCallback: _progressCallBack)
          .then<void>((url) => _onUploadedAudio(url, event))
          .catchError((ex) => {Log.error(ex), _dispatchError()});
    } else
      yield* _getErrorState(error: Config.getString("msg_upload_exceed_audio"));
  }

  //--------------------------------------------------------------------
  Stream<UploadState> _uploadAudioUrl(UploadAudioUrlEvent event) async* {
    uploadService
        .uploadFromUrl(
          event.url,
          progressCallback: _progressCallBack,
        )
        .then<void>((url) => _onUploadedUrl(url, event))
        .catchError(
          (ex) => {
            Log.error(ex),
            Log.debug(ex.toString()),
            _dispatchError(error: 'Your link input error'),
          },
        );
  }

  //---------------------------------------------------------------------
  bool validateFile(File file, _TypeFile type) {
    if (file != null) {
      double size = file.lengthSync() / 1024 / 1024;
      return size < getMaxSizeFromFileType(type);
    } else
      return false;
  }

  int getMaxSizeFromFileType(_TypeFile type) {
    switch (type) {
      case _TypeFile.Audio:
        return this.audioMaxSize;
        break;
      case _TypeFile.Image:
        return this.imageMaxSize;
        break;
      case _TypeFile.Video:
        return this.videoMaxSize;
        break;
      default:
        return this.audioMaxSize;
    }
  }

  Stream<UploadState> _uploadImageSuccess(
      ImageUploadedSuccessEvent event) async* {
    final String url = staticHost + event.response;
    Log.debug('Link image upload: ' + url);
    final component = Image()..url = url;
    yield ImageUploadedSuccess(component, key: event.key);
  }

  Stream<UploadState> _uploadVideoSuccess(
      VideoUploadedSuccessEvent event) async* {
    final String url = staticHost + event.response;
    Log.debug('Link video upload' + url);
    final component = Video()..url = url;
    yield VideoUploadedSuccess(component);
  }

  Stream<UploadState> _uploadAudioSuccess(
      AudioUploadedSuccessEvent event) async* {
    final String url = event.passConfiglink
        ? event.audioData.url
        : staticHost + event.response;

    final Audio component = Audio()
      ..url = url
      ..text = event.audioData?.text ?? ''
      ..textConfig = event.audioData?.textConfig ?? TextConfig();
    yield AudioUploadedSuccess(component, key: event.key);
  }

  Stream<UploadState> _audioUrlUploadedSuccess(
      AudioUrlUploadedSuccessEvent event) async* {
    final String url = staticHost + event.url;
    yield AudioUrlUploadedSuccess(url, key: event.key, text: event.text);
  }

  Stream<UploadState> _getErrorState({String error}) async* {
    yield UploadFailed(error ?? Config.getString("msg_error"));
  }

  void _dispatchError({String error}) {
    add(UploadErrorEvent(error ?? Config.getString("msg_error")));
  }

  void _progressCallBack(int count, int total) {
    try {
      final percen = count / total;
      add(ProgressUploadingEvent(percen));
    } catch (ex) {
      Log.error(ex);
    }
  }

  Future<void> _onUploadedVideo(String resp) async {
    if (resp != null)
      add(VideoUploadedSuccessEvent(resp));
    else
      this._dispatchError();
  }

  Future<void> _onUploadedAudio(String resp, UploadAudioEvent event) async {
    if (resp != null)
      add(AudioUploadedSuccessEvent(
        resp,
        event.audioData,
        key: event.key,
      ));
    else
      this._dispatchError();
  }

  Future<void> onUploadedImage(String resp, UploadImageEvent event) async {
    if (resp != null)
      add(ImageUploadedSuccessEvent(resp, key: event.key));
    else
      this._dispatchError();
  }

  Future<void> _onUploadedUrl(String url, UploadAudioUrlEvent event) async {
    if (url != null) {
      add(AudioUrlUploadedSuccessEvent(url, key: event.key, text: event.text));
    } else
      this._dispatchError(error: 'Upload failed, please try again!');
  }
}
