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

  // ~ 5 m/s ≈ 18 km/h (walking < this, driving > this)
  static const double _speedThresholdMps = 5.0;

  // must stay inside radius this long before triggering
  static const Duration _dwellThreshold = Duration(seconds: 30);

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
      final int id = t.id ?? t.hashCode;

      final distance = Geolocator.distanceBetween(
        currentLat,
        currentLng,
        t.latitude,
        t.longitude,
      );

      final bool inside = distance <= t.radiusMeters;

      if (inside) {
        // First time inside: record entry time
        _taskEnterTimes.putIfAbsent(id, () => now);

        final enterTime = _taskEnterTimes[id]!;
        final dwell = now.difference(enterTime);

        // Already notified before in this session? skip
        if (_alreadyFired.contains(id)) {
          continue;
        }

        // Dwell time check
        if (dwell >= _dwellThreshold) {
          _alreadyFired.add(id);
          await NotificationService.showReminder(t);
        }
      } else {
        // Outside radius: reset dwell timer for this task
        _taskEnterTimes.remove(id);
        // Optionally allow retrigger later by clearing alreadyFired here
        // _alreadyFired.remove(id);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoRemind'),
        actions: [
          IconButton(
            onPressed: _checkNearbyTasks,
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Check nearby reminders',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const Center(
        child: Text('No reminders yet. Tap + to add one.'),
      )
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
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child:
              const Icon(Icons.delete, color: Colors.white),
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
                  color:
                  t.isCompleted ? Colors.green : Colors.grey,
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
