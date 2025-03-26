import 'package:question_app/model/questions.dart';

/// A fill-in-the-blank question with optional image support
class FillInBlankQuestion extends Question {
  FillInBlankQuestion(
      super.stem,
      super.answer,
      {super.figure}
      );

  /// Factory constructor to create a [FillInBlankQuestion] from JSON data
  factory FillInBlankQuestion.fromJson(Map<String, dynamic> json) {
    var stem = json['stem'] as String;
    var answers = List<String>.from(json['answer'] as List<dynamic>);

    return FillInBlankQuestion(
        stem,
        answers,
        figure: json['figure'] as String? // Explicitly pass figure
    );
  }

  @override
  bool isCorrect(String userAnswer) {
    return answer.any(
            (ans) => ans.toLowerCase().trim() == userAnswer.toLowerCase().trim());
  }
}