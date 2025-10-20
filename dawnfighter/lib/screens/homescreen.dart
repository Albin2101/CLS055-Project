import 'package:flutter/material.dart';
import 'social.dart';
import 'alarms.dart';
import 'user.dart';
import '../widgets/navigationBar.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/firestore_service.dart';
import 'package:dawnfighter/screens/ar_view.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int selectedIndex = 1;
  int _localScore = 0;

  final List<Widget> pages = [const Social(), const Alarms(), const User()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Screens
          IndexedStack(index: selectedIndex, children: pages),

          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() => selectedIndex = index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ARviewButton(context),
      
    );
  }
}

Widget ARviewButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppArView()),
      );
    },
    child: const Text('Go to AR View'),
  );
}
