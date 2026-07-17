class Todo {
  int id;
  String title;
  String deadline;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.deadline,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      title: json['title'] as String,
      deadline: json['deadline'] as String,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'completed': completed,
    };
  }
}
