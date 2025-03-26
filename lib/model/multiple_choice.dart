import 'package:question_app/model/questions.dart';

/// A multiple-choice question with optional image support
class MultipleChoiceQuestion extends Question {
  /// List of options for the multiple-choice question
  final List<String> options;

  MultipleChoiceQuestion(
      super.stem,
      super.answer,
      this.options,
      {super.figure}
      );

  /// Factory constructor to create a [MultipleChoiceQuestion] from JSON data
  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    var stem = json['stem'] as String;
    var options = List<String>.from(json['options'] as List<dynamic>);

    // Adjust from 1-based to 0-based indexing
    int answerIndex = (json['answer'] is int)
        ? json['answer'] as int
        : int.parse(json['answer'].toString());
    answerIndex -= 1;

    if (answerIndex < 0 || answerIndex >= options.length) {
      throw RangeError(
          'Answer index $answerIndex is out of bounds for options of length ${options.length}');
    }

    String correctAnswer = options[answerIndex];

    return MultipleChoiceQuestion(
        stem,
        [correctAnswer],
        options,
        figure: json['figure'] as String?
    );
  }

  @override
  bool isCorrect(String userAnswer) {
    // Compare ignoring case and trimming whitespace
    return answer.any(
            (ans) => ans.toLowerCase().trim() == userAnswer.toLowerCase().trim());
  }
}