import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String medicationChannelId = 'medication_reminders';
  static const String activityChannelId = 'activity_reminders';
  static const String emergencyChannelId = 'emergency_alerts';

  static Future<void> initialize({
    required void Function(Map<String, dynamic> payload) onTapPayload,
  }) async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        final map = jsonDecode(payload);
        if (map is Map<String, dynamic>) {
          onTapPayload(map);
        }
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint('Local notification permission granted: $granted');
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          medicationChannelId,
          'Medication Reminders',
          description: 'Daily medication reminders',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          activityChannelId,
          'Activity Reminders',
          description: 'Activity and care task reminders',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          emergencyChannelId,
          'Emergency Alerts',
          description: 'Critical emergency help requests',
          importance: Importance.max,
        ),
      );
      try {
        final exactGranted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Exact alarms permission granted: $exactGranted');
      } catch (e) {
        debugPrint('Exact alarms permission request not available: $e');
      }
    }
    _initialized = true;
  }

  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String channelId,
    required Map<String, dynamic> payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: channelId == emergencyChannelId
              ? Importance.max
              : Importance.high,
          priority: channelId == emergencyChannelId
              ? Priority.max
              : Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required Map<String, dynamic> payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: channelId == emergencyChannelId
              ? Importance.max
              : Importance.high,
          priority: channelId == emergencyChannelId
              ? Priority.max
              : Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(payload),
    );
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required Duration delay,
    required Map<String, dynamic> payload,
  }) async {
    if (!_initialized) {
      await initialize(onTapPayload: (_) {});
    }
    final scheduled = tz.TZDateTime.now(tz.local).add(delay);
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId,
            importance: channelId == emergencyChannelId
                ? Importance.max
                : Importance.high,
            priority: channelId == emergencyChannelId
                ? Priority.max
                : Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(payload),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      debugPrint('One-shot exact schedule failed, fallback inexact: $e');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId,
            importance: channelId == emergencyChannelId
                ? Importance.max
                : Importance.high,
            priority: channelId == emergencyChannelId
                ? Priority.max
                : Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(payload),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
