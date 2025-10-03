import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/reminder_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Map View',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Reminders: ${provider.reminders.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (provider.currentPosition != null) ...[
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Your Current Location:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${provider.currentPosition!.latitude.toStringAsFixed(6)}',
                        ),
                        Text(
                          'Lng: ${provider.currentPosition!.longitude.toStringAsFixed(6)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Note: To enable full map functionality, configure Google Maps API key in Android/iOS configuration files.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
