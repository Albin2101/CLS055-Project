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

tz.TZDateTime _nextWeekday(DateTime baseTime, int dayIndex) {
  final now = tz.TZDateTime.now(tz.local);
  final targetWeekday = dayIndex + 1; // Monday=1, Sunday=7

  int diff = (targetWeekday - now.weekday) % 7;
  if (diff == 0 &&
      (baseTime.hour < now.hour ||
          (baseTime.hour == now.hour && baseTime.minute <= now.minute))) {
    diff = 7; // today has passed → move to next week
  }

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

// Print all pending and verify their times
Future<void> printSchedule() async {
  final pending = await flutterLocalNotificationsPlugin
      .pendingNotificationRequests();
  debugPrint('\nCurrently scheduled notifications:');
  for (var p in pending) {
    debugPrint('- ID: ${p.id}, Title: ${p.title}, Body: ${p.body}');
  }
  debugPrint('Total pending notifications: ${pending.length}\n');
}

Future<void> cancelAllAlarms() async {
  await flutterLocalNotificationsPlugin.cancelAll();
  print('All scheduled alarms cancelled.');
  await printSchedule();
}

Future<void> cancelAlarm(int id, List<bool> days) async {
  try {
    final plugin = flutterLocalNotificationsPlugin;

    // If no repeating days, just cancel the main alarm
    if (!days.contains(true)) {
      await plugin.cancel(id);
      debugPrint('Canceled one-time alarm (id=$id)');
      await printSchedule();
    } else {
      // Cancel all weekly repeats (id*10 + weekdayIndex)
      for (int i = 0; i < 7; i++) {
        if (days[i]) {
          await plugin.cancel(id * 10 + i);
          debugPrint(
            'Canceled weekly alarm for day index $i (id=${id * 10 + i})',
          );
          await printSchedule();
        }
      }
    }

    final pending = await plugin.pendingNotificationRequests();
    debugPrint('Remaining pending notifications: ${pending.length}');
  } catch (e) {
    debugPrint('Error while canceling alarm $id: $e');
  }
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

  if (await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestFullScreenIntentPermission() ==
      false) {
    debugPrint('Full-screen intent permission denied.');
  }

  const androidDetails = AndroidNotificationDetails(
    'alarm_channel_id2',
    'Alarms',
    channelDescription: 'Alarm notifications',
    importance: Importance.max,
    priority: Priority.max,
    fullScreenIntent: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('test'),
    enableVibration: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    actions: [
      AndroidNotificationAction('id_1', 'Turn off', showsUserInterface: true),
    ],
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

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
      payload: 'open_ar',
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
          payload: 'open_ar',
        );
      }
    }
  }

  await printSchedule();
}
