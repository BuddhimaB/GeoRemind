import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/task.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await AppDatabase.instance.getAllTasks();
    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks);
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    final newTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (_) => const TaskFormScreen(),
      ),
    );

    if (newTask != null) {
      await AppDatabase.instance.insertTask(newTask);
      await _loadTasks();
    }
  }

  Future<void> _toggleComplete(Task task) async {
    await AppDatabase.instance.toggleCompleted(task);
    await _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;
    await AppDatabase.instance.deleteTask(task.id!);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoRemind'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('No reminders yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final t = _tasks[index];
                    return Dismissible(
                      key: ValueKey(t.id ?? t.title + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteTask(t),
                      child: ListTile(
                        title: Text(t.title),
                        subtitle: Text(
                          'Radius: ${t.radiusMeters.toStringAsFixed(0)} m\n'
                          'Lat: ${t.latitude.toStringAsFixed(4)}, '
                          'Lng: ${t.longitude.toStringAsFixed(4)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: Icon(
                            t.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: t.isCompleted ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggleComplete(t),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
