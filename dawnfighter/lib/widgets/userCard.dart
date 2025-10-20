import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final int stars;
  final int moons;
  final int suns;

  const UserCard({
    super.key,
    required this.name,
    required this.stars,
    required this.moons,
    required this.suns,
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
                      _statIconText('★', stars),
                      const SizedBox(width: 12),
                      _statIconText('🌙', moons),
                      const SizedBox(width: 12),
                      _statIconText('☀', suns),
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

  Widget _statIconText(String icon, int value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(icon, style: const TextStyle(fontSize: 14, color: Colors.white)),
      const SizedBox(width: 4),
      Text(
        value.toString(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    ],
  );
}
