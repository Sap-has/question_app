import 'package:question_app/model/questions.dart';

/// Class to manage a quiz session with selected questions and user responses.
class QuizSession {
  /// The selected questions for this session.
  final List<Question> selectedQuestions;

  /// Map of questions to the user's provided answer.
  final Map<Question, String> userResponses = {};

  /// Current index of the question being displayed.
  int currentIndex = 0;

  QuizSession(this.selectedQuestions);

  /// Returns the current question or null if no questions.
  Question? get currentQuestion =>
      (currentIndex >= 0 && currentIndex < selectedQuestions.length)
          ? selectedQuestions[currentIndex]
          : null;

  /// Moves to the next question. Returns the new current question.
  Question? nextQuestion() {
    if (currentIndex < selectedQuestions.length - 1) {
      currentIndex++;
      return selectedQuestions[currentIndex];
    }
    return null;
  }

  /// Moves to the previous question. Returns the new current question.
  Question? previousQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      return selectedQuestions[currentIndex];
    }
    return null;
  }

  /// Records the user's answer for a question.
  void recordResponse(Question question, String answer) {
    userResponses[question] = answer;
  }

  /// Grades the session by calculating the number of correct answers.
  int gradeSession() {
    int score = 0;
    for (var question in selectedQuestions) {
      var userAnswer = userResponses[question];
      if (userAnswer != null && question.isCorrect(userAnswer)) {
        score++;
      }
    }
    return score;
  }

  /// Returns a list of questions that were answered incorrectly.
  List<Question> getIncorrectQuestions() {
    List<Question> incorrect = [];
    for (var question in selectedQuestions) {
      var userAnswer = userResponses[question];
      if (userAnswer == null || !question.isCorrect(userAnswer)) {
        incorrect.add(question);
      }
    }
    return incorrect;
  }
}