import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _radiusController = TextEditingController(text: '100');
  // Later we’ll replace these with a map picker / current location
  double _latitude = 6.9271;  // Colombo approx
  double _longitude = 79.8612;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final radius = double.tryParse(_radiusController.text.trim()) ?? 100.0;

    final task = Task(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      radiusMeters: radius,
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Geo Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Buy groceries',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(
                  labelText: 'Radius (meters)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = double.tryParse((value ?? '').trim());
                  if (v == null || v <= 0) {
                    return 'Enter a valid radius';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Temporary location display
              ListTile(
                title: const Text('Location'),
                subtitle: Text(
                  'Lat: ${_latitude.toStringAsFixed(5)}, '
                  'Lng: ${_longitude.toStringAsFixed(5)}',
                ),
                trailing: const Icon(Icons.map),
                onTap: () {
                  // later: open map picker screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Map picker coming soon 🙂'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
