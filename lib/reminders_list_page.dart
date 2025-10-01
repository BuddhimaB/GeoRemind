import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
    required this.createdAt,
  });
}

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage> {
  // Sample data for demonstration
  final List<Reminder> _reminders = [
    Reminder(
      id: '1',
      title: 'Pick up groceries',
      description: 'Don\'t forget to buy milk, bread, and eggs',
      location: 'Walmart Supercenter',
      latitude: 40.7128,
      longitude: -74.0060,
      radius: 100,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Reminder(
      id: '2',
      title: 'Meeting with Sarah',
      description: 'Discuss the project timeline and deliverables',
      location: 'Coffee Bean & Tea Leaf',
      latitude: 40.7589,
      longitude: -73.9851,
      radius: 50,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Reminder(
      id: '3',
      title: 'Gym workout',
      description: 'Leg day - don\'t skip!',
      location: 'Planet Fitness',
      latitude: 40.7505,
      longitude: -73.9934,
      radius: 75,
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Reminder(
      id: '4',
      title: 'Book return',
      description: 'Return the borrowed books before they\'re overdue',
      location: 'New York Public Library',
      latitude: 40.7532,
      longitude: -73.9822,
      radius: 25,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Could navigate to map view in real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map view coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first location-based reminder!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-reminder');
        },
        icon: const Icon(Icons.add_location),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: reminder.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reminder.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reminder.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reminder.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${reminder.radius}m radius',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(reminder.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    reminder.isActive ? Icons.pause_circle : Icons.play_circle,
                    color: reminder.isActive ? Colors.orange : Colors.green,
                  ),
                  onPressed: () => _toggleReminder(reminder),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editReminder(reminder),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReminder(reminder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _toggleReminder(Reminder reminder) {
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = Reminder(
          id: reminder.id,
          title: reminder.title,
          description: reminder.description,
          location: reminder.location,
          latitude: reminder.latitude,
          longitude: reminder.longitude,
          radius: reminder.radius,
          isActive: !reminder.isActive,
          createdAt: reminder.createdAt,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reminder.isActive 
            ? 'Reminder paused' 
            : 'Reminder activated',
        ),
      ),
    );
  }

  void _editReminder(Reminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: Text('Are you sure you want to delete "${reminder.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _reminders.removeWhere((r) => r.id == reminder.id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}