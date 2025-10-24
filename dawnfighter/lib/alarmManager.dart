import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'main.dart';

tz.TZDateTime _nextInstance(DateTime time) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime.from(time, tz.local);

  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

tz.TZDateTime _nextWeekday(DateTime baseTime, int targetIndex) {
  final now = DateTime.now();
  int diff = (targetIndex + 1 - now.weekday) % 7;
  return tz.TZDateTime.local(
    now.year,
    now.month,
    now.day + diff,
    baseTime.hour,
    baseTime.minute,
  );
}

String _weekdayName(int i) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[i];
}

Future<void> _zonedScheduleWithFallback({
  required int id,
  required String title,
  required String body,
  required tz.TZDateTime scheduledDate,
  required NotificationDetails details,
  DateTimeComponents? matchDateTimeComponents,
  String? payload,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  final delay = scheduledDate.difference(now);

  debugPrint('Scheduling notification:');
  debugPrint('- Current time: $now');
  debugPrint('- Scheduled time: $scheduledDate');
  debugPrint('- Delay: ${delay.inSeconds} seconds');

  if (delay.inSeconds <= 0) {
    debugPrint('Warning: Attempted to schedule in the past!');
    return;
  }

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
    debugPrint('Successfully scheduled notification');
  } catch (e) {
    debugPrint('Failed to schedule notification: $e');
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: payload,
    );
    debugPrint('Fell back to inexact scheduling');
  }
}

Future<void> scheduleAlarm({
  required int id,
  required DateTime time,
  required List<bool> days,
}) async {
  debugPrint('Scheduling alarm for local time: ${time.toString()}');

  const androidDetails = AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarms',
    channelDescription: 'Alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    playSound: true,
    enableVibration: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

  // Immediate notification
  await flutterLocalNotificationsPlugin.show(
    998,
    'Immediate Test',
    'This is a test notification to confirm notifications work.',
    notificationDetails,
  );

  if (!days.contains(true)) {
    final scheduledTime = _nextInstance(time);
    debugPrint('Scheduled time calculated: $scheduledTime');

    final now = tz.TZDateTime.now(tz.local);
    if (scheduledTime.isBefore(now)) {
      debugPrint('Warning: Scheduled time is in the past!');
      return;
    }

    await _zonedScheduleWithFallback(
      id: id,
      title: 'Alarm',
      body: 'Time to wake up!',
      scheduledDate: scheduledTime,
      details: notificationDetails,
    );
  } else {
    for (int i = 0; i < 7; i++) {
      if (days[i]) {
        final next = _nextWeekday(time, i);
        await _zonedScheduleWithFallback(
          id: id * 10 + i,
          title: 'Alarm',
          body: 'Wake up — ${_weekdayName(i)}',
          scheduledDate: next,
          details: notificationDetails,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'alarm:${id}_$i',
        );
      }
    }
  }

  // Print all pending and verify their times
  final pending = await flutterLocalNotificationsPlugin
      .pendingNotificationRequests();
  debugPrint('\nCurrently scheduled notifications:');
  for (var p in pending) {
    debugPrint('- ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
  }
  debugPrint('Total pending notifications: ${pending.length}\n');
}
