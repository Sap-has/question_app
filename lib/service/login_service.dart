import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String _baseUrl = 'https://www.cs.utep.edu/cheon/cs4381/homework/quiz/login.php';

  /// Authenticate user with given [username] and [pin]
  Future<bool> login(String username, String pin) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?user=$username&pin=$pin'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['response'] == true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
}