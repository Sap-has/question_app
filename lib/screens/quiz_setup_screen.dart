import 'package:flutter/material.dart';
import 'package:question_app/screens/quiz_screen.dart';
import 'package:question_app/service/quiz_service.dart';
import 'package:question_app/model/quiz_model.dart';

class QuizSetupScreen extends StatefulWidget {
  final String username;
  final String pin;

  const QuizSetupScreen({
    Key? key,
    required this.username,
    required this.pin
  }) : super(key: key);

  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late QuizService _quizService;
  late QuizModel _quizModel;
  bool _isLoading = true;
  int _selectedQuestionCount = 5;

  @override
  void initState() {
    super.initState();
    _quizService = QuizService();
    _loadQuizzes();
  }

  void _loadQuizzes() async {
    try {
      final quizModel = await _quizService.fetchQuizzes(
          widget.username,
          widget.pin
      );

      setState(() {
        _quizModel = quizModel;
        _isLoading = false;
        _selectedQuestionCount =
        _quizModel.getQuestions().length > 5
            ? 5
            : _quizModel.getQuestions().length;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load quizzes'))
      );
    }
  }

  void _startQuiz() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizScreen(
              quizModel: _quizModel,
              questionCount: _selectedQuestionCount,
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Questions Available: ${_quizModel.getQuestions().length}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Select Number of Questions',
              style: TextStyle(fontSize: 16),
            ),
            Slider(
              value: _selectedQuestionCount.toDouble(),
              min: 1,
              max: _quizModel.getQuestions().length.toDouble(),
              divisions: _quizModel.getQuestions().length - 1,
              label: _selectedQuestionCount.toString(),
              onChanged: (double value) {
                setState(() {
                  _selectedQuestionCount = value.toInt();
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startQuiz,
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}