import 'package:flutter/material.dart';
import 'package:question_app/model/multiple_choice.dart';
import 'package:question_app/model/fill_in_blank.dart';
import 'package:question_app/model/questions.dart';
import 'package:question_app/model/quiz_model.dart';
import 'package:question_app/model/quiz_session.dart';
import 'package:question_app/screens/results_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quizModel;
  final int questionCount;

  const QuizScreen({
    Key? key,
    required this.quizModel,
    required this.questionCount
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizSession _quizSession;
  TextEditingController _answerController = TextEditingController();
  Future<Image?>? _currentQuestionImage;

  @override
  void initState() {
    super.initState();
    // Randomly select questions
    List<Question> selectedQuestions = List.from(widget.quizModel.getQuestions())
      ..shuffle();
    selectedQuestions = selectedQuestions.take(widget.questionCount).toList();

    _quizSession = QuizSession(selectedQuestions);
    _loadCurrentQuestionImage();
  }

  void _loadCurrentQuestionImage() {
    final currentQuestion = _quizSession.currentQuestion;
    setState(() {
      _currentQuestionImage = currentQuestion?.fetchImage();
    });
  }

  void _submitAnswer() {
    if (_answerController.text.trim().isEmpty) return;

    _quizSession.recordResponse(
        _quizSession.currentQuestion!,
        _answerController.text.trim()
    );
    _answerController.clear();

    setState(() {
      if (_quizSession.currentIndex < _quizSession.selectedQuestions.length - 1) {
        _quizSession.nextQuestion();
        _loadCurrentQuestionImage();
      } else {
        // Move to results screen
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ResultsScreen(
                    quizSession: _quizSession
                )
            )
        );
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      _quizSession.previousQuestion();
      _loadCurrentQuestionImage();
    });
  }

  void _nextQuestion() {
    setState(() {
      _quizSession.nextQuestion();
      _loadCurrentQuestionImage();
    });
  }

  Widget _buildQuestionImageWidget() {
    return FutureBuilder<Image?>(
      future: _currentQuestionImage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: snapshot.data!,
          );
        }

        return SizedBox.shrink(); // No image or error
      },
    );
  }

  Widget _buildQuestionWidget() {
    final question = _quizSession.currentQuestion!;

    if (question is MultipleChoiceQuestion) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: question.options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () {
                _answerController.text = option;
                _submitAnswer();
              },
              child: Text(option),
            ),
          );
        }).toList(),
      );
    } else if (question is FillInBlankQuestion) {
      return TextField(
        controller: _answerController,
        decoration: InputDecoration(
          hintText: 'Enter your answer',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submitAnswer(),
      );
    }

    return Text('Unsupported question type');
  }

  @override
  Widget build(BuildContext context) {
    if (_quizSession.currentQuestion == null) {
      return Scaffold(
        body: Center(child: Text('No questions available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Question'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: LinearProgressIndicator(
            value: (_quizSession.currentIndex + 1) / _quizSession.selectedQuestions.length,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _quizSession.currentQuestion!.stem,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // Add image widget here
            _buildQuestionImageWidget(),
            SizedBox(height: 20),
            _buildQuestionWidget(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _quizSession.currentIndex > 0 ? _previousQuestion : null,
                  child: Text('Previous'),
                ),
                Text(
                  'Question ${_quizSession.currentIndex + 1} of ${_quizSession.selectedQuestions.length}',
                ),
                ElevatedButton(
                  onPressed: _submitAnswer,
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}