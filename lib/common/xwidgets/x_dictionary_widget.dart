import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart' as core;
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/xwidgets/xwidgets.dart';
import 'package:the_flashcard/deck_creation/audio/x_audio_player.dart';
import 'package:the_flashcard/xerror.dart';

class XDictionaryWidget extends XComponentWidget<core.Dictionary> {
  XDictionaryWidget(
    core.Dictionary componentData,
    int index,
  ) : super(componentData, index);

  @override
  Widget buildComponentWidget(BuildContext context) {
    core.Pronunciation pronunciation;
    String url;

    if (componentData?.pronunciations?.isNotEmpty == true) {
      pronunciation = componentData.pronunciations.firstWhere(
            (item) => item.region?.toLowerCase() == 'us',
            orElse: () => null,
          ) ??
          componentData.pronunciations.first;
      if (componentData.images?.isNotEmpty == true)
        url = componentData.images?.first;
    }

    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Center(child: _Vocabulary(vocabulary: componentData.word)),
        SizedBox(height: hp(15)),
        _PronunciationWidget(pronunciation: pronunciation),
        SizedBox(height: hp(28)),
        _PartOfSpeech(partOfSpeech: componentData.partOfSpeech),
        SizedBox(height: hp(7)),
        _ContentWidget(translations: componentData.translations),
        url != null ? SizedBox(height: hp(36)) : SizedBox(),
        _buildImage(url),
      ],
    );
  }

  Widget _buildImage(String url) {
    return url?.isNotEmpty == true
        ? XCachedImageWidget(
            url: url,
            imageBuilder: (_, ImageProvider imageProvider) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: wp(255),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
            placeholder: (_, __) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: XImageLoading(
                  child: Container(
                    width: wp(255),
                    color: XedColors.white255,
                  ),
                ),
              );
            },
          )
        : SizedBox();
  }
}

class _ContentWidget extends StatelessWidget {
  final List<core.Translation> translations;

  const _ContentWidget({Key key, this.translations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translations = this.translations ?? <core.Translation>[];
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children:
          translations.map<Widget>((item) => _buildContent(item)).toList(),
    );
  }

  Widget _buildContent(core.Translation translation) {
    if (translation != null) {
      String description = translation.description;
      String meaning = translation.meaning;
      List<core.PhraseExample> examples = translation.examples ?? [];

      return Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildDescriptionAndMeaning(description, meaning),
          SizedBox(height: hp(3)),
          _buildExamples(examples),
        ],
      );
    } else
      return SizedBox();
  }

  Widget _buildExamples(List<core.PhraseExample> examples) {
    return Flex(
      direction: Axis.vertical,
      children: examples.map((example) => _buildExampleText(example)).toList(),
    );
  }

  Widget _buildExampleText(core.PhraseExample example) {
    final String text = example.phrase ?? '';
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: wp(10)),
        SizedBox(
          width: wp(8),
          child: Text(
            "•",
            style: LightTextStyle(20),
          ),
        ),
        SizedBox(width: wp(10)),
        Flexible(
          child: _buildText(
            text,
            RegularTextStyle(16).copyWith(
              height: 1.4,
              color: XedColors.battleShipGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionAndMeaning(String description, String meaning) {
    if (description != null && description.isNotEmpty) {
      return _buildText(
        '($description) ${meaning ?? ""}',
        RegularTextStyle(16).copyWith(
          height: 1.4,
          color: XedColors.battleShipGrey,
        ),
      );
    } else {
      return _buildText(
        meaning ?? "",
        RegularTextStyle(16).copyWith(
          height: 1.4,
          color: XedColors.battleShipGrey,
        ),
      );
    }
  }

  Widget _buildText(String text, TextStyle style) {
    return Text(text, style: style);
  }
}

class _PronunciationWidget extends StatelessWidget {
  final core.Pronunciation pronunciation;
  static final speaker = XAudioPlayer();

  const _PronunciationWidget({Key key, this.pronunciation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pronunciation != null) {
      String phonetic = pronunciation.phoneticTranscription ?? '';
      String audioUrl = pronunciation.audioUrl ?? '';
      return Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildSpeaker(audioUrl),
          SizedBox(width: wp(4)),
          Flexible(child: _buildPhonetic(phonetic)),
        ],
      );
    } else
      return SizedBox();
  }

  Widget _buildSpeaker(String urlAudio) {
    return SizedBox(
      height: hp(24),
      width: wp(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        child: Icon(
          Icons.volume_up,
          color: XedColors.waterMelon,
          size: 24,
        ),
        onTap: () => XError.f0(() => _speak(urlAudio)),
      ),
    );
  }

  void _speak(String audioUrl) {
    if (audioUrl == null || audioUrl == '') return;
    speaker.stop();
    speaker.play(audioUrl);
  }

  Widget _buildPhonetic(String phonetic) {
    return phonetic != null
        ? AutoSizeText(
            '|$phonetic|',
            style: BoldPhoneticTextStyle(14).copyWith(
              fontWeight: FontWeight.normal,
              color: XedColors.brownGrey,
            ),
            maxFontSize: 14,
            maxLines: phonetic.length > 20 ? 3 : 1,
          )
        : SizedBox();
  }
}

class _PartOfSpeech extends StatelessWidget {
  final String partOfSpeech;

  const _PartOfSpeech({Key key, this.partOfSpeech}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.partOfSpeech,
      style: SemiBoldTextStyle(14),
    );
  }
}

class _Vocabulary extends StatelessWidget {
  final String vocabulary;

  const _Vocabulary({Key key, this.vocabulary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final word = this.vocabulary ?? '';
    return Text(
      word,
      style: MediumTextStyle(21),
      textAlign: TextAlign.center,
    );
  }
}
