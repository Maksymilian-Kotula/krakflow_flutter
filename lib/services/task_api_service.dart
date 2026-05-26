import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'dart:developer';

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<List<Task>> fetchTasks() async {
    final url = Uri.parse("$baseUrl/todos");

    log("Wysyłam zapytanie pod adres: $url", name: "TaskApiService");

    try {
      final response = await http.get(url);

      log("Otrzymano kod odpowiedzi HTTP: ${response.statusCode}", name: "TaskApiService");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List todos = data["todos"];


        log("Pomyślnie dodano zadanie. Liczba zadań z API: ${todos.length}", name: "TaskApiService");

        return todos.map<Task>((todo) {
          return Task(
            id: todo["id"],
            title: todo["todo"],
            deadline: "brak",
            done: todo["completed"],
            priority: "średni",
          );
        }).toList();
      } else {
        log(
            "Nie udało się pobrać zadań - nieprawidłowy status odpowiedzi",
            name: "TaskApiService",
            error: "Kod statusu: ${response.statusCode}"
        );
        throw Exception("Błąd pobierania danych: ${response.statusCode}");
      }
    } catch (error) {
      log("Wystąpił wyjątek podczas komunikacji z API", name: "TaskApiService", error: error);
      rethrow;
    }
  }
}