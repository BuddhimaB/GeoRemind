import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import '../db/app_database.dart';
import '../models/task.dart';
import '../services/location_service.dart';
import '../services/background_location_service.dart';
import '../services/notification_service.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];
  bool _isLoading = true;

  // UI-level speed setting (default 80 km/h)
  double _speedThresholdMps = 80 / 3.6;

  bool _isExpired(Task t) {
    final expiresAt = t.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await AppDatabase.instance.getAllTasks();
    if (!mounted) return;
    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks);
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    final newTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );

    if (newTask != null) {
      await AppDatabase.instance.insertTask(newTask);
      await _loadTasks();
    }
  }

  Future<void> _editTask(Task task) async {
    final updatedTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(initialTask: task)),
    );

    if (updatedTask != null) {
      await AppDatabase.instance.updateTask(updatedTask);
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

  // Manual check button (works when app is open)
  Future<void> _checkNearbyTasks() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get location. Check GPS & permissions.'),
        ),
      );
      return;
    }

    final currentLat = pos.latitude;
    final currentLng = pos.longitude;

    int triggered = 0;

    for (final t in _tasks) {
      if (_isExpired(t) || t.isCompleted) continue;

      final distance = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        t.latitude,
        t.longitude,
      );

      if (distance <= t.radiusMeters) {
        triggered++;
        await NotificationService.showReminder(t);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          triggered == 0
              ? 'No reminders in range.'
              : 'Triggered $triggered reminder(s). Check notifications.',
        ),
      ),
    );
  }

  Future<void> _startBackgroundMonitoring() async {
    await BackgroundLocationService.start();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Background monitoring started')),
    );
  }

  Future<void> _stopBackgroundMonitoring() async {
    await BackgroundLocationService.stop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Background monitoring stopped')),
    );
  }

  Future<void> _openSettingsDialog() async {
    double tempKmh = _speedThresholdMps * 3.6;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Speed threshold (km/h)'),
                  const SizedBox(height: 8),
                  Text(
                    '${tempKmh.toStringAsFixed(0)} km/h',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    min: 10,
                    max: 120,
                    divisions: 11, // 10,20,...,120
                    value: tempKmh.clamp(10, 120).toDouble(),
                    label: '${tempKmh.toStringAsFixed(0)} km/h',
                    onChanged: (value) {
                      setStateDialog(() => tempKmh = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reminders will be ignored when your speed is above this limit\n'
                        '(e.g., when travelling in a vehicle).',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final newMps = tempKmh / 3.6;

                    setState(() => _speedThresholdMps = newMps);

                    // Send new value to background service
                    FlutterBackgroundService().invoke(
                      "updateSpeedThreshold",
                      {"speedThresholdMps": newMps},
                    );

                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No reminders here.'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];

        final locLabel =
        (t.locationName != null && t.locationName!.trim().isNotEmpty)
            ? t.locationName!.trim()
            : 'Custom location';

        return Dismissible(
          key: ValueKey(t.id ?? '${t.title}-$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteTask(t),
          child: ListTile(
            onTap: () => _editTask(t),
            title: Text(t.title),
            subtitle: Text(
              '$locLabel\nRadius: ${t.radiusMeters.toStringAsFixed(0)} m',
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: Icon(
                t.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: t.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleComplete(t),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks =
    _tasks.where((t) => !t.isCompleted && !_isExpired(t)).toList();

    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    final expiredTasks =
    _tasks.where((t) => !t.isCompleted && _isExpired(t)).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GeoRemind'),
          actions: [
            IconButton(
              onPressed: _checkNearbyTasks,
              icon: const Icon(Icons.notifications_active),
              tooltip: 'Check nearby reminders',
            ),
            IconButton(
              onPressed: _openSettingsDialog,
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
            IconButton(
              onPressed: _startBackgroundMonitoring,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Start monitoring',
            ),
            IconButton(
              onPressed: _stopBackgroundMonitoring,
              icon: const Icon(Icons.stop),
              tooltip: 'Stop monitoring',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildTaskList(activeTasks),
            _buildTaskList(completedTasks),
            _buildTaskList(expiredTasks),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTask,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
