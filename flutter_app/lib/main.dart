import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas App',
      // NOVO: tema claro
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // NOVO: tema escuro
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: TaskListScreen(
        // NOVO: passa o tema e o botão de alternar
        isDark: isDark,
        onToggleTheme: () => setState(() => isDark = !isDark),
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const TaskListScreen({required this.isDark, required this.onToggleTheme});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List tasks = [];

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse('http://localhost:8000/tasks'));
    if (response.statusCode == 200) {
      setState(() {
        tasks = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> createTask(String title) async {
    await http.post(
      Uri.parse('http://localhost:8000/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'done': false}),
    );
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('http://localhost:8000/tasks/$id'));
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ALTERADO: título centralizado com emoji
        title: Text('📝 Tarefas'),
        centerTitle: true,
        // NOVO: botão de alternar tema
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa ainda!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              // NOVO: padding na lista
              padding: EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                // ALTERADO: ListTile dentro de Card com ícone
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.task_alt, color: Colors.deepPurple),
                    title: Text(
                      task['title'],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      // ALTERADO: ícone de lixeira melhorado
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => deleteTask(task['id']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController controller = TextEditingController();
              return AlertDialog(
                title: Text('Nova Tarefa'),
                content: TextField(
                  controller: controller,
                  // NOVO: placeholder e borda no campo
                  decoration: InputDecoration(
                    hintText: 'Digite o nome da tarefa...',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                actions: [
                  // NOVO: botão cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  // ALTERADO: ElevatedButton em vez de TextButton
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        createTask(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        icon: Icon(Icons.add),
        label: Text('Nova Tarefa'),
      ),
    );
  }
}
