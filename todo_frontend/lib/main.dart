import 'package:flutter/material.dart';

import 'models/todo.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> todos = [];

  Future<void> loadTodos() async {
    try {
      final loadedTodos = await ApiService.getTodos();
      if (!mounted) return;
      setState(() {
        todos = loadedTodos;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải danh sách: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
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
                value: todo.completed,
                onChanged: (value) async {
                  if (value == null) return;
                  await updateTodoStatus(todo, value);
                },
              ),
              title: Text(todo.title),
              subtitle: Text('Deadline: ${todo.deadline}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editTodoDialog(todo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTodo(todo.id),
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

  Future<void> updateTodoStatus(Todo todo, bool completed) async {
    try {
      await ApiService.updateTodo(
        id: todo.id,
        title: todo.title,
        deadline: todo.deadline,
        completed: completed,
      );
      await loadTodos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $e')));
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await ApiService.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa thất bại: $e')));
    }
  }

  Future<void> editTodoDialog(Todo todo) async {
    final titleController = TextEditingController(text: todo.title);
    final deadlineController = TextEditingController(text: todo.deadline);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sửa Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: dialogContext,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final formattedDate =
                        '${pickedDate.year}-'
                        '${pickedDate.month.toString().padLeft(2, '0')}-'
                        '${pickedDate.day.toString().padLeft(2, '0')}';

                    deadlineController.text = formattedDate;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.updateTodo(
                    id: todo.id,
                    title: titleController.text,
                    deadline: deadlineController.text,
                    completed: todo.completed,
                  );
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  await loadTodos();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cập nhật thất bại: $e')),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addTodoDialog() async {
    final titleController = TextEditingController();
    final deadlineController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add new Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: dialogContext,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final formattedDate =
                        '${pickedDate.year}-'
                        '${pickedDate.month.toString().padLeft(2, '0')}-'
                        '${pickedDate.day.toString().padLeft(2, '0')}';

                    deadlineController.text = formattedDate;
                  }
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.createTodo(
                    title: titleController.text,
                    deadline: deadlineController.text,
                  );
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  await loadTodos();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể thêm todo: $e')),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }
}
