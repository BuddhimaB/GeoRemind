import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../../presentation/widgets/reminder_card.dart';
import 'add_edit_reminder_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoRemind'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReminderProvider>().loadReminders();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildRemindersList() : const MapScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditReminderScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildRemindersList() {
    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.loadReminders,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (provider.reminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No reminders yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add your first location reminder',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: provider.loadReminders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.reminders.length,
            itemBuilder: (context, index) {
              final reminder = provider.reminders[index];
              return ReminderCard(
                reminder: reminder,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditReminderScreen(
                        reminder: reminder,
                      ),
                    ),
                  );
                },
                onToggle: (isActive) {
                  provider.toggleReminder(reminder.id, isActive);
                },
                onDelete: () {
                  _showDeleteDialog(context, reminder.id);
                },
              );
            },
          ),
        );
      },
    );
  }
  
  void _showDeleteDialog(BuildContext context, String reminderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReminderProvider>().deleteReminder(reminderId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
