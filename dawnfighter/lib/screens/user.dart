import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/userCard.dart';
import '../widgets/settingsCard.dart';
import '../services/firestore_service.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed out')));
      // After sign out, the StreamBuilder in main.dart will show the login screen.
      // Do not call Navigator.pop() here — let the auth-state-driven navigation replace the screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Builder(
          builder: (context) {
            // add extra bottom padding to avoid overlap with a bottom nav bar
            final bottomPadding = MediaQuery.of(context).padding.bottom + 16.0;
            return Padding(
              padding: EdgeInsets.only(
                bottom: bottomPadding,
                left: 8,
                right: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // show decorative user card populated from Firestore
                  StreamBuilder(
                    // use the current authenticated user's uid
                    stream: FirebaseAuth.instance.currentUser == null
                        ? const Stream.empty()
                        : FirestoreService.userStream(
                            FirebaseAuth.instance.currentUser!.uid,
                          ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // while waiting for data, show a placeholder card
                        return const UserCard(
                          name: 'Loading...',
                          points: 0,
                          streak: 0,
                          monsters: 0,
                        );
                      }

                      if (snapshot.hasError) {
                        // on error, show a simple error card
                        return const UserCard(
                          name: 'Error',
                          points: 0,
                          streak: 0,
                          monsters: 0,
                        );
                      }

                      final doc = snapshot.data;
                      if (doc == null || !doc.exists) {
                        return const UserCard(
                          name: 'No profile',
                          points: 0,
                          streak: 0,
                          monsters: 0,
                        );
                      }

                      //parse data,
                      final data = doc.data() as Map<String, dynamic>?;
                      final name = (data != null && data['name'] is String)
                          ? data['name'] as String
                          : 'Player';
                      final points =
                          (data != null &&
                              (data['points'] is int || data['points'] is num))
                          ? (data['points'] as num).toInt()
                          : (data != null &&
                                    (data['score'] is int ||
                                        data['score'] is num)
                                ? (data['score'] as num).toInt()
                                : 0);
                      final streak =
                          (data != null &&
                              (data['streak'] is int || data['streak'] is num))
                          ? (data['streak'] as num).toInt()
                          : 0;
                      final monsters =
                          (data != null &&
                              (data['monsters'] is int ||
                                  data['monsters'] is num))
                          ? (data['monsters'] as num).toInt()
                          : 0;

                      return UserCard(
                        name: name,
                        points: points,
                        streak: streak,
                        monsters: monsters,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // settings / menu card
                  SettingsCard(
                    items: const [
                      'Edit account',
                      'Accessibility',
                      'Manage friends',
                      'Settings',
                      'User guide',
                      'Log out',
                    ],
                    onLogout: _signOut,
                    isLoading: _loading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
