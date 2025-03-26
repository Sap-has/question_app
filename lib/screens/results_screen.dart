import 'package:flutter/material.dart';
import 'package:question_app/model/quiz_session.dart';
import 'package:question_app/screens/login_screen.dart';

class ResultsScreen extends StatelessWidget {
  final QuizSession quizSession;

  const ResultsScreen({Key? key, required this.quizSession}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = quizSession.gradeSession();
    final totalQuestions = quizSession.selectedQuestions.length;
    final incorrectQuestions = quizSession.getIncorrectQuestions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Display
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$score / $totalQuestions',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Incorrect Questions Review
            ExpansionTile(
              title: Text(
                'Incorrect Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              children: incorrectQuestions.map((question) {
                return ListTile(
                  title: Text(question.stem),
                  subtitle: Text('Correct Answer: ${question.answer.join(", ")}'),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Action Buttons
            ElevatedButton(
              onPressed: () {
                // Navigate back to login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              },
              child: Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }
}