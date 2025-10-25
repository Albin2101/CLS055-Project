import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialUserCard extends StatelessWidget {
  final String name;
  final int points;
  final int streak;
  final int monsters;

  const SocialUserCard({
    super.key,
    required this.name,
    required this.points,
    required this.streak,
    required this.monsters,
  });

  @override
  Widget build(BuildContext context) {
    return 
      Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                  'assets/images/userPicture.png',
                  width: 208,
                  height: 208,
                  fit: BoxFit.cover,
                ),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/userCard.png'),
                    fit: BoxFit.fill,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statIconText('assets/icons/Star.svg', points),
                      _statIconText('assets/icons/Flame.svg', streak),
                      _statIconText('assets/icons/Monster.svg', monsters),
                    ],
                  ),
                ),
              ),
            ],
          ),
        Positioned(
            bottom: 49,
            right: 7,
            child: Text(
                name,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'PressStart2P',
                ),
            ),
          ),
      ],
    );
  }

  Widget _statIconText(String assetPath, int value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 28,
        height: 28,
        child: SvgPicture.asset(
          assetPath,
          colorFilter: const ColorFilter.mode(
            Color(0xFF1C1B45),
            BlendMode.srcIn,
          ),
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        value.toString(),
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ],
  );
}
