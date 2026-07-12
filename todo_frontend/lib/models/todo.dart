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
      id: json["id"],
      title: json["title"],
      deadline: json["deadline"],
      completed: json["completed"],
    );
  }
}