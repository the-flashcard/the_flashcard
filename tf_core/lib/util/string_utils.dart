List<String> getLines(String value) {
  final List<String> words = <String>[];

  words.addAll(value
          ?.split(RegExp(r"\n|\r"))
          ?.where((s) => s != null)
          ?.where((word) => word.trim().isNotEmpty) ??
      []);
  return words;
}

List<String> getListWordFromString(String value) {
  final List<String> words = <String>[];

  words.addAll(value
          ?.replaceAll(RegExp(r'\n|\r'), ' ')
          ?.split(RegExp(r"\s+"))
          ?.where((word) => word.isNotEmpty) ??
      []);
  return words;
}

String toPascalCase(String text) {
  if (text != null) {
    final List<String> words = getListWordFromString(text);
    return words.fold<String>('', (total, word) => total.isEmpty
            ? _upperCaseFirstCharacter(word)
            : '$total ${_upperCaseFirstCharacter(word)}');
  } else
    return null;
}

String _upperCaseFirstCharacter(String word) {
  final newWord = '${word[0].toUpperCase()}${word.substring(1)}';
  return newWord;
}

String getHashCode(String text, {String prefix = ''}) {
  if (text is String) {
    return '${prefix}_${text.length}_${text.hashCode}';
  } else {
    return null;
  }
}
