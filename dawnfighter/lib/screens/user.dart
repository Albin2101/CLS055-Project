import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/userCard.dart';
import '../widgets/settingsCard.dart';

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
      // Do not call Navigator.pop() here — let the auth-state-driven
      // navigation replace the screen. Calling pop can inadvertently
      // pop the underlying route in apps that use a bottom navigation bar.
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
                children: [
                  const SizedBox(height: 8),
                  // show decorative user card
                  const UserCard(
                    name: 'Clara',
                    points: 2564,
                    streak: 22,
                    monsters: 36,
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
