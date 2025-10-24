import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'screens/homescreen.dart';
import 'firebase_options.dart';
import 'screens/loginscreen.dart';
import 'screens/ar_view.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Stockholm'));

  // Create notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alarm_channel_id',
    'Alarms',
    description: 'Alarm notifications',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
    enableLights: true,
    sound: RawResourceAndroidNotificationSound('alarm'),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Initialize notifications plugin
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification tapped: ${response.payload}');
      runApp(const AppArView());
    },
  );

  // Request notification permission
  await requestNotificationPermission();
  runApp(const MainApp());
}

Future<void> requestNotificationPermission() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation == null) {
    debugPrint('Unable to resolve Android implementation');
    return;
  }

  final bool? granted = await androidImplementation
      .requestNotificationsPermission();
  debugPrint(
    'Notification permission ${granted == true ? 'granted' : 'denied'}',
  );
}

Future<void> openExactAlarmSettings() async {
  try {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
    debugPrint('Opened exact alarm settings.');
  } catch (e) {
    debugPrint('Failed to open exact alarm settings: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          return user == null ? const LoginTestScreen() : const Homescreen();
        },
      ),
    );
  }
}
