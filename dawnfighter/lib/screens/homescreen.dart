import 'package:flutter/material.dart';
import 'social.dart';
import 'alarms.dart';
import 'user.dart';
import '../widgets/navigationBar.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/firestore_service.dart';

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
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Save score'),
        icon: const Icon(Icons.save),
        onPressed: () async {
          final user = fb_auth.FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No signed-in user')));
            return;
          }
          setState(() => _localScore += 1);
          try {
            await FirestoreService.setUserScore(user.uid, _localScore);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Saved score: $_localScore')),
            );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to save score: $e')));
          }
        },
      ),
    );
  }
}
