class FIBUtils {
  static String format(String questionStr) {
    String question = questionStr;
    List<MapEntry<int, int>> blanks = getBlanks(questionStr);

    if (blanks != null && blanks.isNotEmpty) {
      question = '';
      var lastBlank = MapEntry(0, 0);
      for (int i = 0; i < blanks.length; i++) {
        var blank = blanks[i];

        question += questionStr.substring(lastBlank.value, blank.key);
        question += createBlank(i);
        if (i == blanks.length - 1) {
          question += questionStr.substring(blank.value);
        }
        lastBlank = blank;
      }
    }
    return question;
  }

  static String formatWithAnswers(
      String questionStr, List<String> correctAnswers) {
    String question = format(questionStr);
    var blanks = getBlanks(question);

    String resultedQuestion = '';
    if (blanks != null && blanks.isNotEmpty) {
      resultedQuestion = question.substring(0, blanks[0].key);

      for (int i = 0; i < blanks.length && i < correctAnswers.length; i++) {
        // int start = blanks[i].key;
        int end = blanks[i].value;

        String blankWithAnswer = ' ${correctAnswers[i]} ';

        resultedQuestion = resultedQuestion + blankWithAnswer;
        if (i < correctAnswers.length - 1) {
          resultedQuestion =
              resultedQuestion + question.substring(end, blanks[i + 1].key);
        }

        if (i == correctAnswers.length - 1 &&
            blanks[i].value < question.length) {
          resultedQuestion =
              resultedQuestion + question.substring(blanks[i].value);
        }
      }
    } else if (correctAnswers.isNotEmpty) {
      String correctAnswer = correctAnswers[0];
      resultedQuestion = '$question\n\nAnswer: $correctAnswer';
    } else {
      resultedQuestion = question;
    }

    return resultedQuestion;
  }

  static List<MapEntry<int, int>> getBlanks(String question) {
    final regex = RegExp('[^\\S\\n\\r]*_{3,}(\\s*\\(\\s*\\d+\\s*\\))?[^\\S\\n\\r]*');
    List<MapEntry<int, int>> result;
    if (question != null) {
      result = regex
          .allMatches(question)
          .map((match) => MapEntry(match.start, match.end))
          .fold<List<MapEntry<int, int>>>([], (blanks, entry) {
        blanks.add(entry);
        return blanks;
      });
    } else {
      result = <MapEntry<int, int>>[];
    }

    return result;
  }

  static String createBlank(int index, {String answer = '___'}) {
    return " $answer(${index + 1}) ";
  }

  static List<String> splitQuestion(String question) {
    final regex =
        RegExp('[^\\S\\n\\r]*_{3,}(\\s*\\(\\s*\\d+\\s*\\))?[^\\S\\n\\r]*');
    if (question != null) {
      return question.split(regex);
    } else {
      return [];
    }
  }
}
