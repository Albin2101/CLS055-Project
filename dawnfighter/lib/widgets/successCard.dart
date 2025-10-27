import 'package:dawnfighter/screens/social.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class SuccessCard extends StatelessWidget {
  const SuccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.currentUser == null
          ? const Stream.empty()
          : FirestoreService.userStream(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        // Default values while loading or on error
        int totalPoints = 0;
        int currentStreak = 0;
        int totalMonsters = 0;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          totalPoints =
              (data != null && (data['points'] is int || data['points'] is num))
              ? (data['points'] as num).toInt()
              : (data != null && (data['score'] is int || data['score'] is num)
                    ? (data['score'] as num).toInt()
                    : 0);

          currentStreak =
              (data != null && (data['streak'] is int || data['streak'] is num))
              ? (data['streak'] as num).toInt()
              : 0;

          totalMonsters =
              (data != null &&
                  (data['monsters'] is int || data['monsters'] is num))
              ? (data['monsters'] as num).toInt()
              : 0;
        }

        int pointsEarned = currentStreak > 0 ? currentStreak * 25 : 25;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background card image
            Image.asset(
              "assets/images/successCard.png",
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,
            ),

            // Content overlay
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Star.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFED7AC2),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+$pointsEarned',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 24,
                          color: Color(0xFFED7AC2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Main congratulatory message
                  const Text(
                    'You did it!',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bumling is very happy now!',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description text
                  Text(
                    'This battle has earned you $pointsEarned extra points.\n'
                    'Go and check how your score compares to your friends.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      height: 1.5,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bottom icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statIconText(
                        'assets/icons/Star.svg',
                        totalPoints + pointsEarned,
                      ),
                      _statIconText('assets/icons/Flame.svg', currentStreak),
                      _statIconText('assets/icons/Monster.svg', totalMonsters),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Continue button
                  GestureDetector(
                    onTap: () async {
                      // Update points in Firestore
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirestoreService.updateUserPoints(
                          user.uid,
                          totalPoints + pointsEarned,
                        );
                      }

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Social(),
                          ),
                        );
                      }
                    },
                    child: Image.asset(
                      'assets/images/successcontinue.png',
                      width: 160,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statIconText(String assetPath, int value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      const SizedBox(width: 6),
      Text(
        value.toString(),
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    ],
  );
}
