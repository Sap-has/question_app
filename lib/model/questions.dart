import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Abstract class representing a quiz question with optional image support
abstract class Question {
  /// The text or stem of the question
  final String stem;

  /// The correct answers
  final List<String> answer;

  /// Optional image file name for the question
  final String? figure;

  Question(this.stem, this.answer, {this.figure});

  /// Checks if the [userAnswer] is correct
  bool isCorrect(String userAnswer);

  /// Fetch the image for this question if available
  Future<Image?> fetchImage() async {
    if (figure == null) {
      print('DEBUG: No figure name provided for this question');
      return null;
    }

    try {
      final imageUrl = 'https://www.cs.utep.edu/cheon/cs4381/homework/quiz/figure.php?name=$figure';
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return Image.memory(
          response.bodyBytes,
          fit: BoxFit.contain,
          width: double.infinity,
          height: 200,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }
}
