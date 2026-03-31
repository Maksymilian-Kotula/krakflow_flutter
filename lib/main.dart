import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  List<Task> tasks = [
    Task(title: "Zrobic lab3", deadline: "dzisiaj",done:true,priority:"wysoki"),
    Task(title: "Wf", deadline: "Jutro",done: false, priority:"niski"),
    Task(title: "Napisac storone", deadline: "w tym tygodniu",done: true, priority:"średni"),
  ];

  @override
  Widget build(BuildContext context) {
    int doneTasks = tasks.where((t) => t.done).length;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow"),
        ),
        body:

        ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: tasks.length + 1, // +1 dla nagłówka
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Masz dziś ${tasks.length} zadania"),
                    Text("Wykonane: $doneTasks"),
                    SizedBox(height: 8),
                    Text(
                      "Dzisiejsze zadania",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }
            else {
              final task = tasks[index - 1];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ListTile(
                    leading: Icon(
                      task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 32,
                      color: task.done ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Termin: ${task.deadline}\nPriorytet: ${task.priority}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700]!,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({required this.title, required this.deadline, this.done = false,required this.priority});
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}