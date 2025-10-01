import 'package:flutter/material.dart';
import 'reminders_list_page.dart';
import 'add_reminder_page.dart';

void main() {
  runApp(const GeoRemindApp());
}

class GeoRemindApp extends StatelessWidget {
  const GeoRemindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoRemind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const RemindersListPage(),
      routes: {
        '/add-reminder': (context) => const AddReminderPage(),
      },
    );
  }
}


