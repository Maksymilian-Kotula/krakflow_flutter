import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';
import 'services/notification_service.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista Zadan",
      home: const MojEkranGlownyAplikacji(),
    );
  }
}

class MojEkranGlownyAplikacji extends StatefulWidget {
  const MojEkranGlownyAplikacji({super.key});

  @override
  State<MojEkranGlownyAplikacji> createState() => _MojEkranGlownyAplikacjiState();
}

class _MojEkranGlownyAplikacjiState extends State<MojEkranGlownyAplikacji> {
  String selectedFilter = "wszystkie";
  List<Task> allTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _wczytajZadania();
  }

  Future<void> _wczytajZadania() async {
    try {

      await TaskSyncService.loadInitialDataIfNeeded();


      final tasks = TaskLocalDatabase.getTasks();
      setState(() {
        allTasks = tasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = allTasks;

    if (selectedFilter == "wykonane") {
      filteredTasks = allTasks.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = allTasks.where((task) => !task.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Potwierdzenie"),
                    content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () async {

                          await TaskLocalDatabase.deleteAllTasks();
                          _wczytajZadania();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Wszystkie zadania zostały usunięte")),
                          );
                        },
                        child: const Text("Usuń", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Masz dziś ${allTasks.length} zadania",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => selectedFilter = "wszystkie"),
                  child: Text("Wszystkie",
                      style: TextStyle(color: selectedFilter == "wszystkie" ? Colors.blue : Colors.grey)),
                ),
                TextButton(
                  onPressed: () => setState(() => selectedFilter = "do zrobienia"),
                  child: Text("Do zrobienia",
                      style: TextStyle(color: selectedFilter == "do zrobienia" ? Colors.blue : Colors.grey)),
                ),
                TextButton(
                  onPressed: () => setState(() => selectedFilter = "wykonane"),
                  child: Text("Wykonane",
                      style: TextStyle(color: selectedFilter == "wykonane" ? Colors.blue : Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Dismissible(
                    key: ValueKey(task.id),
                    onDismissed: (direction) async {
                      await TaskLocalDatabase.deleteTask(task.id);
                      _wczytajZadania();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Zadanie usunięte")),
                      );
                    },
                    child: TaskCard(
                      title: task.title,
                      subtitle: "termin: ${task.deadline} | ważność ${task.priority}",
                      done: task.done,
                      onChanged: (newValue) async {
                        final isDone = newValue ?? false;
                        final wasDone = task.done;

                        task.done = isDone;
                        await TaskLocalDatabase.updateTask(task);

                        if (!wasDone && isDone) {
                          await NotificationService.showTaskDoneNotification(task.title);
                        }

                        _wczytajZadania();
                      },
                      onTap: () async {
                        final updatedTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );

                        if (updatedTask != null) {
                          await TaskLocalDatabase.updateTask(updatedTask);
                          _wczytajZadania();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );

          if (newTask != null) {
            await TaskLocalDatabase.addTask(newTask);
            _wczytajZadania();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytul zadania", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: deadlineController, decoration: const InputDecoration(labelText: "Termin", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: priorityController, decoration: const InputDecoration(labelText: "Priorytet", border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
                );
                Navigator.pop(context, newTask);
              },
              child: const Text("zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
    priorityController = TextEditingController(text: widget.task.priority);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytul zadania", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: deadlineController, decoration: const InputDecoration(labelText: "Termin", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: priorityController, decoration: const InputDecoration(labelText: "Priorytet", border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  id: widget.task.id,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: widget.task.done,
                );
                Navigator.pop(context, updatedTask);
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}