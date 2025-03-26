import 'package:question_app/model/multiple_choice.dart';
import 'package:question_app/model/fill_in_blank.dart';
import 'package:question_app/model/questions.dart';

/// Model class representing the quiz data.
class QuizModel {
  /// List of all questions loaded from the web service.
  final List<Question> questions = [];

  /// Loads questions from a JSON quiz.
  /// [quizData] should be the JSON-decoded data representing a quiz.
  void loadQuestionsFromJson(var quiz) {
    for (var quizData in quiz) {
      if (quizData.containsKey('questions')) {
        for (var q in quizData['questions']) {
          int type = q['type'];
          if (type == 1) {
            questions.add(MultipleChoiceQuestion.fromJson(q));
          } else if (type == 2) {
            questions.add(FillInBlankQuestion.fromJson(q));
          }
        }
      }
    }
  }

  /// Returns an unmodifiable list of all loaded questions.
  List<Question> getQuestions() => List.unmodifiable(questions);
}