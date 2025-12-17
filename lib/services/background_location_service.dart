import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

import '../db/app_database.dart';
import '../models/task.dart';
import 'notification_service.dart';

class BackgroundLocationService {
  static Future<void> init() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true, // IMPORTANT
        autoStart: false,       // we'll start manually
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: (_) async => false,
      ),
    );
  }

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Required so plugins work in background isolate
    // DartPluginRegistrant.ensureInitialized();

    // Init notifications inside background isolate
    await NotificationService.init();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "GeoRemind is running",
        content: "Monitoring location for reminders...",
      );
    }

    service.on("stopService").listen((event) {
      service.stopSelf();
    });

    // ---- YOUR GEO LOGIC STARTS HERE ----

    // Cache: taskId -> enterTime
    final Map<int, DateTime> enterTimes = {};
    final Set<int> alreadyFired = {};

    // Default speed threshold (80 km/h)
    double speedThresholdMps = 80 / 3.6;

    const dwellThreshold = Duration(seconds: 30);

    // Load tasks periodically (so edits/additions reflect)
    List<Task> tasks = await AppDatabase.instance.getAllTasks();

    Timer.periodic(const Duration(seconds: 20), (t) async {
      tasks = await AppDatabase.instance.getAllTasks();
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    StreamSubscription<Position>? sub;

    // Start listening
    sub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (pos) async {
        final speed = pos.speed;

        // Speed filter
        if (speed != null && speed > speedThresholdMps) {
          enterTimes.clear();
          return;
        }

        final now = DateTime.now();
        final lat = pos.latitude;
        final lng = pos.longitude;

        for (final t in tasks) {
          final id = t.id ?? t.hashCode;

          // Skip completed tasks (optional)
          if (t.isCompleted) continue;

          final distance = Geolocator.distanceBetween(
            lat,
            lng,
            t.latitude,
            t.longitude,
          );

          final inside = distance <= t.radiusMeters;

          if (inside) {
            enterTimes.putIfAbsent(id, () => now);
            final enteredAt = enterTimes[id]!;
            final dwell = now.difference(enteredAt);

            if (alreadyFired.contains(id)) continue;

            if (dwell >= dwellThreshold) {
              alreadyFired.add(id);
              await NotificationService.showReminder(t);
            }
          } else {
            enterTimes.remove(id);
          }
        }
      },
    );

    // Clean stop
    service.on("stopService").listen((event) async {
      await sub?.cancel();
      service.stopSelf();
    });
  }
}
