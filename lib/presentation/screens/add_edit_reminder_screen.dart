import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/reminder.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../../core/constants/app_constants.dart';
import 'location_picker_screen.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  
  const AddEditReminderScreen({super.key, this.reminder});
  
  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  double? _latitude;
  double? _longitude;
  double _radius = AppConstants.defaultRadius;
  ReminderPriority _priority = ReminderPriority.medium;
  bool _isActive = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description ?? '';
      _locationController.text = widget.reminder!.locationName;
      _latitude = widget.reminder!.latitude;
      _longitude = widget.reminder!.longitude;
      _radius = widget.reminder!.radius;
      _priority = widget.reminder!.priority;
      _isActive = widget.reminder!.isActive;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _useCurrentLocation,
                    ),
                    IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: _pickLocation,
                    ),
                  ],
                ),
              ),
              readOnly: true,
              validator: (value) {
                if (_latitude == null || _longitude == null) {
                  return 'Please select a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Radius: ${_radius.toInt()}m',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _radius,
              min: AppConstants.minRadius,
              max: AppConstants.maxRadius,
              divisions: 99,
              label: '${_radius.toInt()}m',
              onChanged: (value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReminderPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag),
              ),
              items: ReminderPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getPriorityColor(priority),
                      ),
                      const SizedBox(width: 8),
                      Text(_getPriorityName(priority)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Enable location monitoring'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.reminder == null ? 'Create Reminder' : 'Update Reminder'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _useCurrentLocation() async {
    setState(() => _isSaving = true);
    
    final provider = context.read<ReminderProvider>();
    await provider.getCurrentLocation();
    
    if (provider.currentPosition != null) {
      final position = provider.currentPosition!;
      _latitude = position.latitude;
      _longitude = position.longitude;
      
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _locationController.text = '${place.street ?? ''}, ${place.locality ?? ''}';
        } else {
          _locationController.text = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        }
      } catch (e) {
        _locationController.text = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      }
      
      setState(() {});
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    }
    
    setState(() => _isSaving = false);
  }
  
  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _latitude = result['latitude'] as double;
        _longitude = result['longitude'] as double;
        _locationController.text = result['locationName'] as String;
      });
    }
  }
  
  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final reminder = Reminder(
      id: widget.reminder?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      latitude: _latitude!,
      longitude: _longitude!,
      locationName: _locationController.text,
      radius: _radius,
      isActive: _isActive,
      createdAt: widget.reminder?.createdAt ?? DateTime.now(),
      priority: _priority,
    );
    
    final provider = context.read<ReminderProvider>();
    
    if (widget.reminder == null) {
      await provider.createReminder(reminder);
    } else {
      await provider.updateReminder(reminder);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
  
  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.green;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.high:
        return Colors.red;
    }
  }
  
  String _getPriorityName(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return 'Low';
      case ReminderPriority.medium:
        return 'Medium';
      case ReminderPriority.high:
        return 'High';
    }
  }
}
