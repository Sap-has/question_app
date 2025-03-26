import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:question_app/model/quiz_model.dart';

class QuizService {
  static const String _baseUrl = 'https://www.cs.utep.edu/cheon/cs4381/homework/quiz/quiz.php';

  /// Fetch quizzes for a given [username] and [pin]
  Future<QuizModel> fetchQuizzes(String username, String pin) async {
    QuizModel quizModel = QuizModel();
    int quizNumber = 1;

    while (true) {
      // Ensure two-digit format for quiz numbers
      String quizId = 'quiz${quizNumber.toString().padLeft(2, '0')}';

      try {
        final response = await http.get(
          Uri.parse('$_baseUrl?user=$username&pin=$pin&quiz=$quizId'),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          // Check if the response indicates a valid quiz
          if (jsonResponse['response'] == true && jsonResponse.containsKey('quiz')) {
            var quizData = [jsonResponse['quiz']];
            quizModel.loadQuestionsFromJson(quizData);
            quizNumber++;
          } else {
            // If response is false or no quiz found, stop loading
            break;
          }
        } else {
          // HTTP error, stop loading
          break;
        }
      } catch (e) {
        print('Error fetching quiz $quizId: $e');
        break;
      }
    }

    return quizModel;
  }
}