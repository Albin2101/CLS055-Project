import 'package:dawnfighter/screens/homescreen.dart';
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
        int totalPoints = 0;
        int currentStreak = 0;
        int totalMonsters = 0;

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          totalPoints = (data?['points'] ?? data?['score'] ?? 0) is num
              ? (data?['points'] ?? data?['score']).toInt()
              : 0;
          currentStreak = (data?['streak'] ?? 0) is num
              ? (data?['streak'] as num).toInt()
              : 0;
          totalMonsters = (data?['monsters'] ?? 0) is num
              ? (data?['monsters'] as num).toInt()
              : 0;
        }

        int pointsEarned = currentStreak > 0 ? currentStreak * 25 : 25;

        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/victoryCard.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                    'assets/icons/Star.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFE997EE),
                      BlendMode.srcIn,
                    ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                    '+$pointsEarned',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 24,
                      color: Color(0xFFE997EE),
                    ),
                    ),
                  ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                  'You did it!',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 18,
                    color: Color(0xFF1C1B45),
                  ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                  'Bumling is very happy now!',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 20,
                    color: Color(0xFF1C1B45),
                  ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                  'This battle has earned you $pointsEarned extra points.'
                  'Go and check how your score compares to your friends.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF1C1B45),
                  ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statIconText('assets/icons/Star.svg', totalPoints + pointsEarned),
                    _statIconText('assets/icons/Flame.svg', currentStreak),
                    _statIconText('assets/icons/Monster.svg', totalMonsters),
                  ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                  onTap: () async {
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
                      builder: (context) => const Homescreen(),
                      ),
                    );
                    }
                  },
                  child: Image.asset(
                    'assets/images/successContinue.png',
                    height: 56,
                  ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statIconText(String assetPath, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xFF1C1B45), BlendMode.srcIn),
        ),
        const SizedBox(width: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 12,
            color: Color(0xFF1C1B45),
          ),
        ),
      ],
    );
  }
}
