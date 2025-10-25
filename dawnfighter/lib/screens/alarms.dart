import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../widgets/alarmCard.dart';
import '../alarmManager.dart';
import 'editAlarm.dart';

class Alarms extends StatefulWidget {
  const Alarms({super.key});

  @override
  State<Alarms> createState() => _AlarmsState();
}

class _AlarmsState extends State<Alarms> {
  int? _deleteIndex; // which card is in delete-mode (null = none)

  List<Map<String, dynamic>> alarms = [
    {
      'time': DateTime.parse('2025-10-24 20:00:04Z'),
      'days': [false, false, false, false, true, true, false],
      'enabled': true,
    },
    {
      'time': DateTime.now(),
      'days': [false, false, false, false, false, false, false],
      'enabled': true,
    },
  ];

  Future<void> _editAlarm(int index) async {
    // clear delete-mode before editing
    setState(() => _deleteIndex = null);

    final alarm = alarms[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditAlarm(initialTime: alarm['time'], initialDays: alarm['days']),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        alarms[index]['time'] = result['time'];
        alarms[index]['days'] = result['days'];
      });

      await scheduleAlarm(
        id: index,
        time: result['time'],
        days: result['days'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 70, bottom: 10),
              child: Text(
                'YOUR\nALARMS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),

            // Scrollable list
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 50,
                    ),
                    child: Column(
                      children: [
                        // AlarmCards
                        ...alarms.asMap().entries.map((entry) {
                          final index = entry.key;
                          final alarm = entry.value;
                          final time = alarm['time'] as DateTime;
                          final formattedTime =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: AlarmCard(
                              title: formattedTime,
                              value: alarm['enabled'],
                              days: alarm['days'],
                              showDelete: _deleteIndex == index,
                              onChanged: (val) async {
                                setState(() => alarms[index]['enabled'] = val);

                                final alarm = alarms[index];
                                if (val) {
                                  await scheduleAlarm(
                                    id: index,
                                    time: alarm['time'],
                                    days: alarm['days'],
                                  );
                                } else {
                                  await cancelAlarm(index, alarm['days']);
                                }
                              },
                              onTap: () => _editAlarm(index),
                              onLongPress: () =>
                                  setState(() => _deleteIndex = index),
                              onCancelDelete: () =>
                                  setState(() => _deleteIndex = null),
                              onDelete: () async {
                                final alarm = alarms[index];
                                await cancelAlarm(index, alarm['days']);
                                setState(() {
                                  alarms.removeAt(index);
                                  _deleteIndex = null;
                                });
                              },
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 10),

                        // Add button
                        GestureDetector(
                          onTap: () async {
                            setState(() => _deleteIndex = null);
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditAlarm(isNew: true),
                              ),
                            );

                            if (result != null && mounted) {
                              setState(() {
                                alarms.add({
                                  'time': result['time'],
                                  'days': result['days'],
                                  'enabled': true,
                                });
                              });

                              await scheduleAlarm(
                                id: alarms.length,
                                time: result['time'],
                                days: result['days'],
                              );
                            }
                          },
                          child: Container(
                            width: 320,
                            height: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                opacity: 0.5,
                                image: AssetImage(
                                  'assets/images/alarmCard.png',
                                ),
                                fit: BoxFit.fill,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Center(
                                child: Icon(
                                  Pixel.plus,
                                  size: 80,
                                  color: Color(0xFFE997EE).withAlpha(130),
                                ),
                              ),
                            ),
                          ),
                        ),

                        /* ElevatedButton(
                          onPressed: () async {
                            await cancelAllAlarms();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All alarms cancelled'),
                                ),
                              );
                            }
                          },
                          child: const Text('Cancel All Alarms'),
                        ), */
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
