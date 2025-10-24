import 'package:dawnfighter/widgets/socialUserCard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/userCard.dart';
import '../services/firestore_service.dart';
import '../widgets/leaderboardCard.dart';

class Social extends StatefulWidget {
  const Social({super.key});

  @override
  State<Social> createState() => _SocialState();
}

class _SocialState extends State<Social> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            StreamBuilder(
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

                final data = doc.data() as Map<String, dynamic>?;
                final name = (data != null && data['name'] is String)
                    ? data['name'] as String
                    : 'Player';
                final points =
                    (data != null &&
                        (data['points'] is int || data['points'] is num))
                    ? (data['points'] as num).toInt()
                    : (data != null &&
                              (data['score'] is int || data['score'] is num)
                          ? (data['score'] as num).toInt()
                          : 0);
                final streak =
                    (data != null &&
                        (data['streak'] is int || data['streak'] is num))
                    ? (data['streak'] as num).toInt()
                    : 0;
                final monsters =
                    (data != null &&
                        (data['monsters'] is int || data['monsters'] is num))
                    ? (data['monsters'] as num).toInt()
                    : 0;

                return SocialUserCard(
                  name: name,
                  points: points,
                  streak: streak,
                  monsters: monsters,
                );
              },
            ),
            const SizedBox(height: 12),
            // show leaderboard under the user card
            const LeaderboardCard(),
          ],
        ),
      ),
    );
  }
}
