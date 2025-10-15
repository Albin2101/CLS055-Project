import 'package:flutter/material.dart';
import '../widgets/alarmCard.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool switch1 = false;
  bool switch2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'MY ALARMS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 30),

                  AlarmCard(
                    imagePath: 'assets/images/alarmCard.png',
                    title: 'Card One',
                    value: switch1,
                    onChanged: (val) => setState(() => switch1 = val),
                  ),

                  const SizedBox(height: 30),

                  AlarmCard(
                    imagePath: 'assets/images/alarmCard.png',
                    title: 'Card Two',
                    value: switch2,
                    onChanged: (val) => setState(() => switch2 = val),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
