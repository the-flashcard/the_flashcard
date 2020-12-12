import 'dart:async';
import 'dart:io';

import 'package:ddi/di.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/xed_exceptions.dart';
import 'package:the_flashcard/common/widgets/x_button_sheet_action_widget.dart';
import 'package:the_flashcard/deck_creation/audio_creation/audio_creation_screen.dart';
import 'package:the_flashcard/deck_creation/audio_creation/audio_editing_screen.dart';
import 'package:the_flashcard/deck_creation/image/search_image_screen.dart';
import 'package:the_flashcard/deck_creation/video/x_bottom_sheet_textfield.dart';
import 'package:the_flashcard/environment/driver_key.dart';

class XChooseVideoPopup extends _XChoosePopupException
    with _XChoosePopupSubmitCallBack {
  final BuildContext context;

  final ValueChanged<File> onFileSelected;
  final ValueChanged<String> onUrlSelected;
  final VoidCallback onCancel;
  final String preScreenName;

  XChooseVideoPopup({
    @required this.context,
    @required this.onFileSelected,
    @required this.onUrlSelected,
    @required ValueChanged<Exception> onError,
    @required this.preScreenName,
    this.onCancel,
  }) : super(context: context, onError: onError);

  Future<void> show() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_record_video"),
              onTap: () => _onTapRecord(context),
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_input_youtube_link"),
              onTap: () => _onTapInputLink(context),
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_choose_from_library"),
              onTap: () => _onTapChooseFromLib(context),
            ),
          ],
          cancelButton: XButtonSheetActionWidget(
            text: 'Cancel',
            onTap: () {
              submitCancel(context, this.onCancel, this.preScreenName);
            },
            style: BoldTextStyle(16).copyWith(color: XedColors.waterMelon),
          ),
        );
      },
    );
  }

  void _onTapChooseFromLib(BuildContext context) async {
    try {
      // File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
      File file = await FilePicker.getFile(type: FileType.video);
      // file ??= await retrieveLostData();

      if (file != null)
        submitFile(context, onFileSelected, file, this.preScreenName);
      else {
        submitCancel(context, this.onCancel, this.preScreenName);
      }
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onTapInputLink(BuildContext context) async {
    try {
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => XBottomSheetTextFieldWidget(
          valueKey: DriverKey.EDIT_DECK_INFO,
          title: core.Config.getString("msg_input_youtube_link"),
          hintText: core.Config.getString("msg_paste_link_here"),
          onSubmit: (url) => this.submitUrl(
            context,
            onUrlSelected,
            url,
            this.preScreenName,
          ),
          textInputAction: TextInputAction.done,
        ),
      );
      this.submitCancel(context, this.onCancel, preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onTapRecord(BuildContext context) async {
    try {
      File file = await ImagePicker.pickVideo(source: ImageSource.camera);
      file ??= await retrieveLostData();

      if (file != null)
        submitFile(context, onFileSelected, file, this.preScreenName);
      else
        submitCancel(context, this.onCancel, this.preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }
}

typedef UrlWithText = void Function(String url, String text);

class XChooseAudioPopup extends _XChoosePopupException
    with _XChoosePopupSubmitCallBack {
  final BuildContext context;

  final ValueChanged<AudioData> onAudioDataSubmitted;
  final ValueChanged<String> onUrlSelected;
  final UrlWithText onVocabularySelected;

  final VoidCallback onCancel;
  final bool showInputTextField;
  final String preScreenName;

  XChooseAudioPopup({
    @required this.context,
    @required this.onAudioDataSubmitted,
    @required ValueChanged<Exception> onError,
    @required this.preScreenName,
    @required this.onUrlSelected,
    @required this.onVocabularySelected,
    this.onCancel,
    this.showInputTextField = true,
  }) : super(context: context, onError: onError);

  Future<void> show() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_search_vocabulary"),
              onTap: () => _onTapChooseVocabulary(context),
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_record_audio"),
              onTap: () => _onTapRecord(context),
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_input_audio_link"),
              onTap: () => _onTapInputLink(context),
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_choose_from_library"),
              onTap: () => _onTapChooseFromLib(context),
            ),
          ],
          cancelButton: XButtonSheetActionWidget(
            text: 'Cancel',
            onTap: () {
              submitCancel(context, this.onCancel, this.preScreenName);
            },
            style: BoldTextStyle(16).copyWith(color: XedColors.waterMelon),
          ),
        );
      },
    );
  }

  void _onTapChooseVocabulary(BuildContext context) async {
    try {
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => XBottomSheetTextFieldWidget(
          title: core.Config.getString("msg_search_vocabulary"),
          hintText: core.Config.getString("msg_input_word"),
          onSubmit: _searchVocabulary,
          textInputAction: TextInputAction.done,
        ),
      );
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _searchVocabulary(String query) async {
    try {
      core.XDictService service = DI.get(core.XDictService);
      core.DictionaryRecord record = await service.lookup(query);
      String word = record?.word ?? '';
      String pos = record?.partOfSpeech[0] ?? '';
      String phonetic =
          record?.data[pos]?.pronunciations[0]?.phoneticTranscription ?? '';
      String url = record?.data[pos]?.pronunciations[0]?.audioUrl?.trim();
      if (url?.isNotEmpty == true)
        _submitVocabulary('$word /$phonetic/', url);
      else
        throw Exception("Not exists audio");
    } catch (ex) {
      submitErrorToServer('Vocabulary: [$query] is not available');
      notifyError(
        ex: VocabularyException(
          core.Config.getString("msg_vocab_not_available"),
        ),
      );
    }
  }

  void _onTapInputLink(BuildContext context) async {
    try {
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => XBottomSheetTextFieldWidget(
          title: core.Config.getString("msg_input_audio_link"),
          hintText: core.Config.getString("msg_paste_link_here"),
          onSubmit: _submitUrl,
          textInputAction: TextInputAction.done,
          valueKey: DriverKey.EDIT_DECK_INFO,
        ),
      );
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _submitVocabulary(String text, String url) {
    submitUrlAndText(
      context,
      this.onVocabularySelected,
      url.trim(),
      text,
      preScreenName,
    );
  }

  void _submitUrl(String url) {
    this.submitUrl(
      context,
      this.onUrlSelected,
      url?.trim(),
      preScreenName,
    );
  }

  void _onTapRecord(BuildContext context) async {
    try {
      AudioData data;
      data = await navigateToScreen(
        child: AudioCreationScreen(showInputTextField: this.showInputTextField),
        name: AudioCreationScreen.name,
      ) as AudioData;
      core.Log.debug("Tap record");

      if (data?.file != null) {
        submitAudioData(
          context,
          onAudioDataSubmitted,
          data,
          this.preScreenName,
        );
      } else
        submitCancel(context, onCancel, this.preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onTapChooseFromLib(BuildContext context) async {
    try {
      File file = await FilePicker.getFile(type: FileType.audio);
      String filePath = file?.path;
      if (filePath != null) {
        AudioData data = await navigateToScreen(
          child: AudioEditingScreen.local(
            audioName: filePath,
            showInputTextField: this.showInputTextField,
            showIconRemove: false,
          ),
          name: AudioEditingScreen.name,
        ) as AudioData;
        if (data?.file != null) {
          submitAudioData(
              context, onAudioDataSubmitted, data, this.preScreenName);
        } else
          submitCancel(context, onCancel, this.preScreenName);
      } else {
        submitCancel(context, this.onCancel, this.preScreenName);
      }
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  Future navigateToScreen({@required Widget child, String name}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => child,
        settings: name != null ? RouteSettings(name: name) : null,
      ),
    );
  }
}

class XChooseImagePopup extends _XChoosePopupException
    with _XChoosePopupSubmitCallBack {
  final BuildContext context;

  final ValueChanged<File> onFileSelected;
  final VoidCallback onCancel;
  final VoidCallback onDownloadingFile;
  final VoidCallback onCompleteDownloadFile;

  final double ratioX;
  final double ratioY;
  final bool hideSearchImage;
  final String preScreenName;

  XChooseImagePopup({
    @required this.onDownloadingFile,
    @required this.onCompleteDownloadFile,
    @required this.context,
    @required this.onFileSelected,
    @required ValueChanged<Exception> onError,
    @required this.preScreenName,
    this.onCancel,
    this.ratioX,
    this.ratioY,
    this.hideSearchImage = false,
  }) : super(context: context, onError: onError);

  Future<void> show() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            hideSearchImage
                ? SizedBox()
                : XButtonSheetActionWidget(
                    text: core.Config.getString("msg_search_photo"),
                    onTap: _onSearchPhoto,
                  ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_take_a_photo"),
              onTap: _onTakePhoto,
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_input_image_link"),
              onTap: _onInputLink,
            ),
            XButtonSheetActionWidget(
              text: core.Config.getString("msg_choose_from_library"),
              onTap: _onTapChooseFromGallery,
            ),
          ],
          cancelButton: XButtonSheetActionWidget(
            text: 'Cancel',
            onTap: () {
              submitCancel(context, this.onCancel, this.preScreenName);
            },
            style: BoldTextStyle(16).copyWith(color: XedColors.waterMelon),
          ),
        );
      },
    );
  }

  void _onSearchPhoto() async {
    try {
      String url = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => SearchImageScreen(),
        ),
      );
      if (url != null) {
        await _onDownloadAndSubmitLink(url, true);
      } else {
        submitCancel(context, this.onCancel, this.preScreenName);
      }
      submitCancel(context, this.onCancel, this.preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onTakePhoto() async {
    try {
      File file = await ImagePicker.pickImage(source: ImageSource.camera);
      file ??= await retrieveLostData();

      if (file != null)
        await _cropAndSubmitFile(file);
      else
        submitCancel(context, this.onCancel, this.preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onInputLink() async {
    try {
      await showCupertinoModalPopup(
        context: context,
        builder: (_) => XBottomSheetTextFieldWidget(
          valueKey: DriverKey.INPUT_LINK,
          title: core.Config.getString("msg_input_image_link"),
          hintText: core.Config.getString("msg_paste_link_here"),
          onSubmit: _onCheckLinkAndSubmitLink,
          textInputAction: TextInputAction.done,
        ),
      );
      this.submitCancel(context, this.onCancel, preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onCheckLinkAndSubmitLink(String url) async {
    try {
      if (url is String && url.isNotEmpty) {
        await _onDownloadAndSubmitLink(url.trim(), false);
      }
      // else {
      //   notifyError(ex: Exception('Link is empty'));
      // }
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  void _onTapChooseFromGallery() async {
    try {
      File file = await ImagePicker.pickImage(source: ImageSource.gallery);
      file ??= await retrieveLostData();
      if (file != null)
        await _cropAndSubmitFile(file);
      else
        submitCancel(context, this.onCancel, this.preScreenName);
    } catch (ex) {
      submitErrorToServer(ex);
      notifyError(ex: ex);
    }
  }

  ///--------------------------------------------------------

  Future<void> _cropAndSubmitFile(File file) async {
    if (file != null)
      submitFile(context, this.onFileSelected, file, this.preScreenName);
    else
      submitCancel(context, this.onCancel, this.preScreenName);
  }

  Future<void> _onDownloadAndSubmitLink(
      String imageUrl, bool passCheckUrl) async {
    if (passCheckUrl || core.UrlUtils.isFormatImage(imageUrl)) {
      String fileName = core.UrlUtils.getFileName();
      try {
        core.Log.debug('downloading... $fileName from $imageUrl');
        if (this.onDownloadingFile != null) this.onDownloadingFile();
        File file = await core.UrlUtils.downloadFile(imageUrl, fileName);
        core.Log.debug('Downloading completed: $file');
        if (this.onCompleteDownloadFile != null) this.onCompleteDownloadFile();
        if (file != null)
          await _cropAndSubmitFile(file);
        else
          submitCancel(context, this.onCancel, this.preScreenName);
      } catch (ex) {
        notifyError(ex: Exception('Link error'));
      }
    } else {
      notifyError(ex: Exception('Link error'));
    }
  }
}

class _XChoosePopupException {
  final ValueChanged<Exception> onError;
  final BuildContext context;

  _XChoosePopupException({this.context, @required this.onError});

  void submitErrorToServer(dynamic message) {
    core.Log.error(message);
  }

  void notifyError({Exception ex}) {
    _closePopup();
    if (onError != null) onError(ex);
  }

  void _closePopup() {
    if (context != null && Navigator.canPop(context)) Navigator.pop(context);
  }
}

class _XChoosePopupSubmitCallBack {
  void submitFile(BuildContext context, ValueChanged<File> func, File file,
      String preScreenName) {
    closePopup(context, preScreenName);
    if (func != null) func(file);
  }

  void submitUrlAndText(BuildContext context, UrlWithText func, String url,
      String text, String preScreenName) {
    closePopup(context, preScreenName);

    if (func != null) func(url, text);
  }

  void submitUrl(BuildContext context, ValueChanged<String> func, String link,
      String preScreenName) {
    closePopup(context, preScreenName);

    if (func != null && link?.isNotEmpty == true) func(link);
  }

  void submitCancel(
      BuildContext context, VoidCallback func, String preScreenName) {
    closePopup(context, preScreenName);
    if (func != null) func();
  }

  void submitAudioData(BuildContext context, ValueChanged<AudioData> func,
      AudioData data, String preScreenName) {
    closePopup(context, preScreenName);
    if (func != null) func(data);
  }

  void closePopup(BuildContext context, String preScreenName) {
    if (Navigator.canPop(context))
      Navigator.popUntil(context, ModalRoute.withName(preScreenName));
  }
}

Future<File> retrieveLostData() async {
  if (Platform.isAndroid) {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    return response?.file;
  }
  return null;
}
