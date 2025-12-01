import 'package:flutter/material.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // For now, just keep an in-memory list. We’ll wire this to SQLite later.
  final List<Task> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoRemind'),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final t = _tasks[index];
                return ListTile(
                  title: Text(t.title),
                  subtitle: Text('Radius: ${t.radiusMeters.toStringAsFixed(0)} m'),
                  trailing: Icon(
                    t.isCompleted ? Icons.check_circle : Icons.location_on,
                    color: t.isCompleted ? Colors.green : Colors.blue,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // we’ll navigate to TaskFormScreen later
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

