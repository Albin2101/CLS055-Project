import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import '../widgets/alarmCard.dart';

class Alarms extends StatefulWidget {
  const Alarms({super.key});

  @override
  State<Alarms> createState() => _AlarmsState();
}

class _AlarmsState extends State<Alarms> {
  List<String> alarms = ['07:00', '06:45']; // Alarms
  List<bool> switches = [true, true]; // Switch states
  List<List<bool>> alarmDays = [
    // Active days
    [true, true, true, true, true, false, false],
    [false, true, false, true, true, true, false],
  ];

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
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),

            // Scrollable list
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 36,
                  ),
                  child: Column(
                    children: [
                      // AlarmCards
                      ...alarms.asMap().entries.map((entry) {
                        final index = entry.key;
                        final time = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: AlarmCard(
                            title: time,
                            days: alarmDays[index],
                            value: switches[index],
                            onChanged: (val) {
                              setState(() {
                                switches[index] = val;
                              });
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Add button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                alarms.add('08:00');
                                switches.add(true);
                                alarmDays.add([
                                  true,
                                  true,
                                  true,
                                  true,
                                  true,
                                  false,
                                  false,
                                ]);
                              });
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Pixel.circle,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Pixel.plus,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Remove button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (alarms.isNotEmpty) {
                                  alarms.removeLast();
                                  switches.removeLast();
                                  alarmDays.removeLast();
                                }
                              });
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Pixel.circle,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Pixel.minus,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),
                    ],
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
