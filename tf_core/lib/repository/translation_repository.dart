import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tf_core/tf_core.dart';

abstract class TranslationRepository {
  Future<TranslationResponse> translate(
    String text,
    String targetLang, {
    String sourceLang,
  });

  List<SupportedLanguage> getLanguages();

  Future<Map<String, String>> multiTranslate(
    List<String> texts,
    String targetLang, {
    String sourceLang,
  });
  Future<TextToSpeechResponse> textToSpeech(
    String category,
    String lang,
    String text,
  );
}

class TranslationRepositoryImpl extends TranslationRepository {
  @protected
  final HttpClient client;

  TranslationRepositoryImpl(this.client);

  @override
  Future<TranslationResponse> translate(
    String text,
    String targetLang, {
    String sourceLang,
  }) {
    final params = {
      'text': text,
      'target_lang': targetLang,
      'source_lang': sourceLang
    };
    return client
        .get('/api/translate/text', params: params)
        .then((json) => TranslationResponse.fromJson(json));
  }

  @override
  List<SupportedLanguage> getLanguages() {
    List<SupportedLanguage> list = List<SupportedLanguage>();
    final List<Map<String, dynamic>> data =
        json.decode(_languages)?.cast<Map<String, dynamic>>();
    for (int i = 0; i < data.length; i++) {
      list.add(SupportedLanguage.fromJson(data[i]));
    }
    return list;
  }

  @override
  Future<Map<String, String>> multiTranslate(
    List<String> texts,
    String targetLang, {
    String sourceLang,
  }) {
    final body = <String, dynamic>{
      'texts': texts,
      'target_lang': targetLang,
    };
    if (sourceLang != null) body['source_lang'] = sourceLang;
    return client
        .post('/api/translate/text/multi', body)
        .then((_) => _castToMap(_));
  }

  Map<String, String> _castToMap(Map<dynamic, dynamic> value) {
    return value.cast<String, String>();
  }

  @override
  Future<TextToSpeechResponse> textToSpeech(
      String category, String lang, String text) {
    {
      final params = {
        'category': category,
        'lang': lang,
        'text': text,
      };
      return client
          .get('/api/translate/tts', params: params)
          .then((json) => TextToSpeechResponse.fromJson(json));
    }
  }
}

final String _languages = """
  [
 
    {
      "code": "vi",
      "name": "Vietnamese"
    },
    {
      "code": "af",
      "name": "Afrikaans"
    },
    {
      "code": "sq",
      "name": "Albanian"
    },
    {
      "code": "am",
      "name": "Amharic"
    },
    {
      "code": "ar",
      "name": "Arabic"
    },
    {
      "code": "hy",
      "name": "Armenian"
    },
    {
      "code": "az",
      "name": "Azerbaijani"
    },
    {
      "code": "eu",
      "name": "Basque"
    },
    {
      "code": "be",
      "name": "Belarusian"
    },
    {
      "code": "bn",
      "name": "Bengali"
    },
    {
      "code": "bs",
      "name": "Bosnian"
    },
    {
      "code": "bg",
      "name": "Bulgarian"
    },
    {
      "code": "ca",
      "name": "Catalan"
    },
    {
      "code": "ceb",
      "name": "Cebuano"
    },
    {
      "code": "ny",
      "name": "Chichewa"
    },
    {
      "code": "zh",
      "name": "Chinese (Simplified)"
    },
    {
      "code": "zh-TW",
      "name": "Chinese (Traditional)"
    },
    {
      "code": "co",
      "name": "Corsican"
    },
    {
      "code": "hr",
      "name": "Croatian"
    },
    {
      "code": "cs",
      "name": "Czech"
    },
    {
      "code": "da",
      "name": "Danish"
    },
    {
      "code": "nl",
      "name": "Dutch"
    },
    {
      "code": "en",
      "name": "English"
    },
    {
      "code": "eo",
      "name": "Esperanto"
    },
    {
      "code": "et",
      "name": "Estonian"
    },
    {
      "code": "tl",
      "name": "Filipino"
    },
    {
      "code": "fi",
      "name": "Finnish"
    },
    {
      "code": "fr",
      "name": "French"
    },
    {
      "code": "fy",
      "name": "Frisian"
    },
    {
      "code": "gl",
      "name": "Galician"
    },
    {
      "code": "ka",
      "name": "Georgian"
    },
    {
      "code": "de",
      "name": "German"
    },
    {
      "code": "el",
      "name": "Greek"
    },
    {
      "code": "gu",
      "name": "Gujarati"
    },
    {
      "code": "ht",
      "name": "Haitian Creole"
    },
    {
      "code": "ha",
      "name": "Hausa"
    },
    {
      "code": "haw",
      "name": "Hawaiian"
    },
    {
      "code": "iw",
      "name": "Hebrew"
    },
    {
      "code": "hi",
      "name": "Hindi"
    },
    {
      "code": "hmn",
      "name": "Hmong"
    },
    {
      "code": "hu",
      "name": "Hungarian"
    },
    {
      "code": "is",
      "name": "Icelandic"
    },
    {
      "code": "ig",
      "name": "Igbo"
    },
    {
      "code": "id",
      "name": "Indonesian"
    },
    {
      "code": "ga",
      "name": "Irish"
    },
    {
      "code": "it",
      "name": "Italian"
    },
    {
      "code": "ja",
      "name": "Japanese"
    },
    {
      "code": "jw",
      "name": "Javanese"
    },
    {
      "code": "kn",
      "name": "Kannada"
    },
    {
      "code": "kk",
      "name": "Kazakh"
    },
    {
      "code": "km",
      "name": "Khmer"
    },
    {
      "code": "ko",
      "name": "Korean"
    },
    {
      "code": "ku",
      "name": "Kurdish (Kurmanji)"
    },
    {
      "code": "ky",
      "name": "Kyrgyz"
    },
    {
      "code": "lo",
      "name": "Lao"
    },
    {
      "code": "la",
      "name": "Latin"
    },
    {
      "code": "lv",
      "name": "Latvian"
    },
    {
      "code": "lt",
      "name": "Lithuanian"
    },
    {
      "code": "lb",
      "name": "Luxembourgish"
    },
    {
      "code": "mk",
      "name": "Macedonian"
    },
    {
      "code": "mg",
      "name": "Malagasy"
    },
    {
      "code": "ms",
      "name": "Malay"
    },
    {
      "code": "ml",
      "name": "Malayalam"
    },
    {
      "code": "mt",
      "name": "Maltese"
    },
    {
      "code": "mi",
      "name": "Maori"
    },
    {
      "code": "mr",
      "name": "Marathi"
    },
    {
      "code": "mn",
      "name": "Mongolian"
    },
    {
      "code": "my",
      "name": "Myanmar (Burmese)"
    },
    {
      "code": "ne",
      "name": "Nepali"
    },
    {
      "code": "no",
      "name": "Norwegian"
    },
    {
      "code": "ps",
      "name": "Pashto"
    },
    {
      "code": "fa",
      "name": "Persian"
    },
    {
      "code": "pl",
      "name": "Polish"
    },
    {
      "code": "pt",
      "name": "Portuguese"
    },
    {
      "code": "pa",
      "name": "Punjabi"
    },
    {
      "code": "ro",
      "name": "Romanian"
    },
    {
      "code": "ru",
      "name": "Russian"
    },
    {
      "code": "sm",
      "name": "Samoan"
    },
    {
      "code": "gd",
      "name": "Scots Gaelic"
    },
    {
      "code": "sr",
      "name": "Serbian"
    },
    {
      "code": "st",
      "name": "Sesotho"
    },
    {
      "code": "sn",
      "name": "Shona"
    },
    {
      "code": "sd",
      "name": "Sindhi"
    },
    {
      "code": "si",
      "name": "Sinhala"
    },
    {
      "code": "sk",
      "name": "Slovak"
    },
    {
      "code": "sl",
      "name": "Slovenian"
    },
    {
      "code": "so",
      "name": "Somali"
    },
    {
      "code": "es",
      "name": "Spanish"
    },
    {
      "code": "su",
      "name": "Sundanese"
    },
    {
      "code": "sw",
      "name": "Swahili"
    },
    {
      "code": "sv",
      "name": "Swedish"
    },
    {
      "code": "tg",
      "name": "Tajik"
    },
    {
      "code": "ta",
      "name": "Tamil"
    },
    {
      "code": "te",
      "name": "Telugu"
    },
    {
      "code": "th",
      "name": "Thai"
    },
    {
      "code": "tr",
      "name": "Turkish"
    },
    {
      "code": "uk",
      "name": "Ukrainian"
    },
    {
      "code": "ur",
      "name": "Urdu"
    },
    {
      "code": "uz",
      "name": "Uzbek"
    },
    {
      "code": "cy",
      "name": "Welsh"
    },
    {
      "code": "xh",
      "name": "Xhosa"
    },
    {
      "code": "yi",
      "name": "Yiddish"
    },
    {
      "code": "yo",
      "name": "Yoruba"
    },
    {
      "code": "zu",
      "name": "Zulu"
    }
  ]
  """;
