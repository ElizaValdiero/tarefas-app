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
      debugShowCheckedModeBanner: false,
      //tema claro
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //tema escuro
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: TaskListScreen(
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
      body: jsonEncode({'title': title, 'status': 'a_iniciar'}),
    );
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('http://localhost:8000/tasks/$id'));
    fetchTasks();
  }

  Future<void> updateStatus(int id, String status) async {
    final task = tasks.firstWhere((t) => t['id'] == id);
    await http.put(
      Uri.parse('http://localhost:8000/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': task['title'], 'status': status}),
    );
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarefas 📝 ',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.onToggleTheme,
            ),
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

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      task['status'] == 'finalizada'
                          ? Icons.check_circle
                          : task['status'] == 'em_andamento'
                          ? Icons.timelapse
                          : Icons.radio_button_unchecked,
                      color: task['status'] == 'finalizada'
                          ? Colors.green
                          : task['status'] == 'em_andamento'
                          ? Colors.orange
                          : Colors.blue,
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      task['status'] == 'finalizada'
                          ? '🟢 Finalizada'
                          : task['status'] == 'em_andamento'
                          ? '🟡 Em andamento'
                          : '🔵 A iniciar',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (status) =>
                              updateStatus(task['id'], status),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'a_iniciar',
                              child: Text('🔵 A iniciar'),
                            ),
                            PopupMenuItem(
                              value: 'em_andamento',
                              child: Text('🟡 Em andamento'),
                            ),
                            PopupMenuItem(
                              value: 'finalizada',
                              child: Text('🟢 Finalizada'),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => deleteTask(task['id']),
                        ),
                      ],
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
