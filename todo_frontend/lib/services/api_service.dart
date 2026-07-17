import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/todo.dart';

class ApiService {
  static Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse(ApiEndpoints.todos));

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => Todo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Todo> createTodo({
    required String title,
    required String deadline,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.todos),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'deadline': deadline}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Todo> updateTodo({
    required int id,
    required String title,
    required String deadline,
    required bool completed,
  }) async {
    final response = await http.put(
      Uri.parse(ApiEndpoints.todoById(id)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'deadline': deadline,
        'completed': completed,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }

    return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse(ApiEndpoints.todoById(id)));

    if (response.statusCode != 200) {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  }
}
