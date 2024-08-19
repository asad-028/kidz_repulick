
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> getUsers() async {
  final response = await http.get(Uri.parse('https://portal.kidzrepublik.com.pk/login.php'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    // return data.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}
