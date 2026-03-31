import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MojEkranGlowny(),
    );
  }
}

class MojEkranGlowny extends StatefulWidget {
  const MojEkranGlowny({super.key});

  @override
  _MojEkranGlownyState createState() => _MojEkranGlownyState();
}

class _MojEkranGlownyState extends State<MojEkranGlowny> {
  @override
  Widget build(BuildContext context) {
    // Liczymy wykonane zadania
    int doneTasks = TaskRepository.tasks.where((t) => t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: TaskRepository.tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Nagłówek z podsumowaniem
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Masz dziś ${TaskRepository.tasks.length} zadania"),
                  Text("Wykonane: $doneTasks"),
                  SizedBox(height: 8),
                  Text(
                    "Dzisiejsze zadania",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else {
            final task = TaskRepository.tasks[index - 1];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  task.done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.done ? Colors.green : Colors.red,
                ),
                title: Text(task.title),
                subtitle: Text("Termin: ${task.deadline}\nPriorytet: ${task.priority}"),
                // Brak onTap, więc kliknięcie nie zmienia stanu
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Dodawanie nowego zadania
          setState(() {
            TaskRepository.tasks.add(Task(
              title: "Nowe zadanie",
              deadline: "jutro",
              done: false,
              priority: "niski",
            ));
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}