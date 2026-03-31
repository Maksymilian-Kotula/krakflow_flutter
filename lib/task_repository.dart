// task_repository.dart

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    this.done = false,
    required this.priority,
  });
}

class TaskRepository {

  static List<Task> tasks = [
    Task(title: "Zrobic lab3", deadline: "dzisiaj", done: true, priority: "wysoki"),
    Task(title: "Wf", deadline: "Jutro", done: false, priority: "niski"),
    Task(title: "Napisac storone", deadline: "w tym tygodniu", done: true, priority: "średni"),
  ];
}