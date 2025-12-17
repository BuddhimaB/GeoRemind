import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../db/app_database.dart';
import '../models/task.dart';
import '../services/location_service.dart';
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

  StreamSubscription<Position>? _positionSub;

  // taskId -> first time we detected user inside its radius
  final Map<int, DateTime> _taskEnterTimes = {};

  // tasks already notified during this app session
  final Set<int> _alreadyFired = {};

  // User-configurable speed threshold (default 80 km/h)
  double _speedThresholdMps = 80 / 3.6; // ≈ 22.22 m/s

  // must stay inside radius this long before triggering
  static const Duration _dwellThreshold = Duration(seconds: 30);

  bool _isExpired(Task t) {
    final expiresAt = t.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  Future<void> _editTask(Task task) async {
    final updatedTask = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(initialTask: task),
      ),
    );

    if (updatedTask != null) {
      await AppDatabase.instance.updateTask(updatedTask);
      await _loadTasks();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _startLocationMonitoring();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _startLocationMonitoring() async {
    // Ensure we have permission & services enabled
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location not available. Enable GPS & grant permission to use auto monitoring.',
            ),
          ),
        );
      }
      return;
    }

    // Cancel old subscription if any
    await _positionSub?.cancel();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // meters; adjust for battery vs accuracy
    );

    _positionSub =
        Geolocator.getPositionStream(locationSettings: settings)
            .listen(_handlePositionUpdate);
  }

  Future<void> _handlePositionUpdate(Position pos) async {
    // Speed filter: ignore if moving too fast (likely in vehicle)
    final speed = pos.speed; // m/s, may be 0 or -1 on some devices
    if (speed != null && speed > _speedThresholdMps) {
      // Moving fast: reset enter times so dwell must restart when slowing down
      _taskEnterTimes.clear();
      return;
    }

    final currentLat = pos.latitude;
    final currentLng = pos.longitude;
    final now = DateTime.now();

    for (final t in _tasks) {
      // ⬇️ skip expired or completed tasks
      if (_isExpired(t) || t.isCompleted) continue;

      final int id = t.id ?? t.hashCode;

      final distance = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        t.latitude,
        t.longitude,
      );

      final bool inside = distance <= t.radiusMeters;

      if (inside) {
        _taskEnterTimes.putIfAbsent(id, () => now);

        final enterTime = _taskEnterTimes[id]!;
        final dwell = now.difference(enterTime);

        if (_alreadyFired.contains(id)) {
          continue;
        }

        if (dwell >= _dwellThreshold) {
          _alreadyFired.add(id);
          await NotificationService.showReminder(t);
        }
      } else {
        _taskEnterTimes.remove(id);
        // _alreadyFired.remove(id); // optional
      }
    }
  }

  Future<void> _openSettingsDialog() async {
    // convert current m/s to km/h for UI
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
                      setStateDialog(() {
                        tempKmh = value;
                      });
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
                  onPressed: () {
                    setState(() {
                      _speedThresholdMps = tempKmh / 3.6; // back to m/s
                    });
                    Navigator.of(context).pop();
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

  Future<void> _checkNearbyTasks() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get current location. Check GPS and permissions.',
            ),
          ),
        );
      }
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

    if (mounted) {
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
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await AppDatabase.instance.getAllTasks();
    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks);
      _isLoading = false;

      // Clean up enter times & fired set for removed tasks
      final ids = _tasks.map((t) => t.id ?? t.hashCode).toSet();
      _taskEnterTimes.removeWhere((taskId, _) => !ids.contains(taskId));
      _alreadyFired.removeWhere((taskId) => !ids.contains(taskId));
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

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No reminders here.'),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
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
            onTap: () => _editTask(t),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _tasks
        .where((t) => !t.isCompleted && !_isExpired(t))
        .toList();

    final completedTasks = _tasks
        .where((t) => t.isCompleted)
        .toList();

    final expiredTasks = _tasks
        .where((t) => !t.isCompleted && _isExpired(t))
        .toList();

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
