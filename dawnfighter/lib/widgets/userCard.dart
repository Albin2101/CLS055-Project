import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserCard extends StatelessWidget {
  final String name;
  final int points;
  final int streak;
  final int monsters;

  const UserCard({
    super.key,
    required this.name,
    required this.points,
    required this.streak,
    required this.monsters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 84,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/userCard.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            // avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/userPicture.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            // name & stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statIconText('assets/icons/Star.svg', points),
                      const SizedBox(width: 12),
                      _statIconText('assets/icons/Flame.svg', streak),
                      const SizedBox(width: 12),
                      _statIconText('assets/icons/Monster.svg', monsters),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statIconText(String assetPath, int value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 20,
        height: 20,
        child: SvgPicture.asset(
          assetPath,
          colorFilter: const ColorFilter.mode(Color(0xFF1C1B45), BlendMode.srcIn), 
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        value.toString(),
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    ],
  );
}
