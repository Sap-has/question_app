import 'package:flutter/material.dart';
import 'package:question_app/model/quiz_session.dart';
import 'package:question_app/model/questions.dart';
import 'package:question_app/model/multiple_choice.dart';
import 'package:question_app/model/fill_in_blank.dart';
import 'package:question_app/screens/login_screen.dart';

class ResultsScreen extends StatelessWidget {
  final QuizSession quizSession;

  const ResultsScreen({Key? key, required this.quizSession}) : super(key: key);

  // Helper method to get question type
  String getQuestionType(Question question) {
    if (question is MultipleChoiceQuestion) {
      return 'Multiple Choice';
    } else if (question is FillInBlankQuestion) {
      return 'Fill-in-the-blank';
    }
    return 'Unknown';
  }

  // Helper method to get user's answer (if any)
  String getUserAnswer(Question question, String? userAnswer) {
    if (userAnswer == null) return 'No answer';

    if (question is MultipleChoiceQuestion) {
      // For multiple choice, find the selected option
      int index = question.options.indexWhere(
              (option) => option.toLowerCase().trim() == userAnswer.toLowerCase().trim()
      );
      return index != -1 ? question.options[index] : 'Invalid selection';
    }

    return userAnswer;
  }

  @override
  Widget build(BuildContext context) {
    final score = quizSession.gradeSession();
    final totalQuestions = quizSession.selectedQuestions.length;
    final incorrectQuestions = quizSession.getIncorrectQuestions();
    final percentage = (score / totalQuestions * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Quiz Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Score: $score/$totalQuestions ($percentage%)',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: score / totalQuestions,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        score / totalQuestions >= 0.7 ? Colors.green : Colors.orange,
                      ),
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Incorrect Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Question')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Your Answer')),
                      DataColumn(label: Text('Correct Answer')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: List.generate(
                      incorrectQuestions.length,
                          (index) {
                        final question = incorrectQuestions[index];
                        final userAnswer = quizSession.userResponses[question];

                        // Truncate question text if too long
                        final displayText = question.stem.length > 40
                            ? '${question.stem.substring(0, 40)}...'
                            : question.stem;

                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                              // Highlight incorrect rows in red
                              return Colors.red[100];
                            },
                          ),
                          cells: [
                            DataCell(Text('${incorrectQuestions.indexOf(question) + 1}')),
                            DataCell(Text(displayText)),
                            DataCell(Text(getQuestionType(question))),
                            DataCell(Text(getUserAnswer(question, userAnswer))),
                            DataCell(Text(question.answer.join(', '))),
                            DataCell(
                              const Icon(Icons.cancel, color: Colors.red),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}