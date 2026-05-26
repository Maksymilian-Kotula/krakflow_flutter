import 'package:hive_ce/hive.dart';
import '../models/task.dart';
import 'dart:developer';

class TaskLocalDatabase {
  static Box get _box => Hive.box("tasks");

  static List<Task> getTasks() {
    final tasks = _box.values.map((item) {
      return Task.fromMap(Map<String, dynamic>.from(item));
    }).toList();

    log("Odczytano ${tasks.length} zadań z lokalnej bazy", name: "TaskLocalDatabase");

    return tasks;
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();

    for (final task in tasks) {
      await _box.put(task.id, task.toMap());
    }

    log("Nadpisano bazę listą ${tasks.length} zadań", name: "TaskLocalDatabase");
  }

  static Future<void> addTask(Task task) async {
    await _box.put(task.id, task.toMap());


    log("Dodano nowe zadanie: '${task.title}' (ID: ${task.id})", name: "TaskLocalDatabase");
  }

  static Future<void> updateTask(Task task) async {
    await _box.put(task.id, task.toMap());


    log("Zaktualizowano zadanie / zmieniono status (ID: ${task.id})", name: "TaskLocalDatabase");
  }

  static Future<void> deleteTask(int id) async {
    await _box.delete(id);


    log("Usunięto zadanie (ID: $id)", name: "TaskLocalDatabase");
  }

  static Future<void> deleteAllTasks() async {
    await _box.clear();


    log("Usunięto wszystkie zadania (wyczyszczono bazę)", name: "TaskLocalDatabase");
  }

  static bool isEmpty() {
    return _box.isEmpty;
  }
}