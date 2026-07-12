import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/api_endpoints.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: TodoPage());
  }
}

class TodoPage extends StatefulWidget {
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List todos = [];

  Future<void> loadTodos() async {
    final response = await http.get(Uri.parse(ApiEndpoints.todos));

    setState(() {
      todos = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todo List")),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadTodos();
        },

        child: ListView.builder(
          itemCount: todos.length,

          itemBuilder: (context, index) {
            final todo = todos[index];

            return ListTile(
              leading: Checkbox(
                value: todo["completed"],
                onChanged: (value) async {
                  await updateTodoStatus(todo, value!);
                },
              ),

              title: Text(todo["title"]),

              subtitle: Text("Deadline: ${todo["deadline"]}"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      editTodoDialog(todo);
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteTodo(todo["id"]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          addTodoDialog();
        },
      ),
    );
  }

  Future updateTodoStatus(Map todo, bool completed) async {
    await http.put(
      Uri.parse("${ApiEndpoints.todos}/${todo["id"]}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": todo["title"],
        "deadline": todo["deadline"],
        "completed": completed,
      }),
    );

    loadTodos();
  }

  Future deleteTodo(int id) async {
    await http.delete(Uri.parse("${ApiEndpoints.todos}/$id"));
    loadTodos();
  }

  Future editTodoDialog(Map todo) async {
    TextEditingController titleController = TextEditingController(
      text: todo["title"],
    );

    TextEditingController deadlineController = TextEditingController(
      text: todo["deadline"],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa Todo"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              TextField(
                controller: deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Deadline",
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.year}-"
                        "${pickedDate.month.toString().padLeft(2, '0')}-"
                        "${pickedDate.day.toString().padLeft(2, '0')}";

                    deadlineController.text = formattedDate;
                  }
                },
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),

            ElevatedButton(
              onPressed: () async {
                await http.put(
                  Uri.parse("${ApiEndpoints.todos}/${todo["id"]}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "title": titleController.text,
                    "deadline": deadlineController.text,
                    "completed": todo["completed"],
                  }),
                );

                Navigator.pop(context);

                loadTodos();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Future addTodoDialog() async {
    TextEditingController titleController = TextEditingController();

    TextEditingController deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm Todo"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              TextField(
                controller: deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Deadline",
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.year}-"
                        "${pickedDate.month.toString().padLeft(2, '0')}-"
                        "${pickedDate.day.toString().padLeft(2, '0')}";

                    deadlineController.text = formattedDate;
                  }
                },
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () async {
                await http.post(
                  Uri.parse(ApiEndpoints.todos),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "title": titleController.text,
                    "deadline": deadlineController.text,
                  }),
                );

                Navigator.pop(context);

                loadTodos();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }
}
