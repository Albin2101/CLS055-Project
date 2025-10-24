import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeaderboardCard extends StatelessWidget {
  /// Maximum number of players to show. Pass null to show all.
  final int? maxItems;

  const LeaderboardCard({super.key, this.maxItems = 6});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _placeholder();
        }

        if (snapshot.hasError) {
          return _errorCard();
        }

        final docs = snapshot.data?.docs ?? [];

        // Map docs to players with a canonical score value, then sort client-side
        final players = docs.map((d) {
          final data = d.data();
          final name = (data['name'] is String)
              ? data['name'] as String
              : 'Player';
          final points = (data['points'] is num)
              ? (data['points'] as num).toInt()
              : ((data['score'] is num) ? (data['score'] as num).toInt() : 0);
          return {'name': name, 'points': points};
        }).toList();

        players.sort(
          (a, b) => (b['points'] as int).compareTo(a['points'] as int),
        );

        final visible = (maxItems != null && players.length > maxItems!)
            ? players.sublist(0, maxItems!)
            : players;

        return _buildCard(context, visible);
      },
    );
  }

  Widget _placeholder() => Container(
    width: double.infinity,
    height: 220,
    decoration: BoxDecoration(
      color: const Color(0xFF7A3DA9),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
      ],
    ),
    alignment: Alignment.center,
    child: const Text(
      'Loading leaderboard...',
      style: TextStyle(color: Colors.white, fontFamily: 'PressStart2P'),
    ),
  );

  Widget _errorCard() => Container(
    width: double.infinity,
    height: 220,
    decoration: BoxDecoration(
      color: const Color(0xFF7A3DA9),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
      ],
    ),
    alignment: Alignment.center,
    child: const Text(
      'Could not load leaderboard',
      style: TextStyle(color: Colors.white, fontFamily: 'PressStart2P'),
    ),
  );

  Widget _buildCard(BuildContext context, List<Map<String, Object>> players) {
    return Container(
      width: double.infinity,
      // height sized to show ~6 items comfortably
      constraints: const BoxConstraints(minHeight: 321, maxHeight: 321),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/leaderboardCard.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                ' Leaderboard',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: players.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final p = players[index];
                  final rank = index + 1;
                  final name = p['name'] as String;
                  final points = p['points'] as int;
                  return _leaderboardRow(rank, name, points);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaderboardRow(int rank, String name, int points) {
    final rankText = rank.toString().padLeft(2, '0');
    return Row(
      children: [
        // rank
        SizedBox(
          width: 56,
          child: Text(
            '$rankText.',
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),

        // name
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 14,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // points + star icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              points.toString(),
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                'assets/icons/Star.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFF1C1B45),
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
