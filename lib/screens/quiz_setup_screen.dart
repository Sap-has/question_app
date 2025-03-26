import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Text editing controller for number of questions
  final TextEditingController _questionCountController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

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

        // Set default value to 5 or max available questions
        int defaultQuestionCount = quizModel.getQuestions().length > 5 ? 5 : quizModel.getQuestions().length;
        _questionCountController.text = defaultQuestionCount.toString();
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
    // Validate the form before starting the quiz
    if (_formKey.currentState!.validate()) {
      int questionCount = int.parse(_questionCountController.text);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuizScreen(
                quizModel: _quizModel,
                questionCount: questionCount,
              )
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Questions Available: ${_quizModel.getQuestions().length}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Number of Questions',
                style: TextStyle(fontSize: 16),
              ),
              TextFormField(
                controller: _questionCountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Enter number of questions',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of questions';
                  }

                  int? count = int.tryParse(value);
                  if (count == null || count < 1) {
                    return 'Please enter a valid number';
                  }

                  if (count > _quizModel.getQuestions().length) {
                    return 'Cannot exceed total available questions (${_quizModel.getQuestions().length})';
                  }

                  return null;
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
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed
    _questionCountController.dispose();
    super.dispose();
  }
}