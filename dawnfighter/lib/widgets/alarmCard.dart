import 'package:flutter/material.dart';

class AlarmCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final List<bool> days;

  const AlarmCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/alarmCard.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: value ? Colors.white : Color(0xFF391B4F),
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(7, (index) {
                    final day = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
                    final isActive = days[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          color: isActive
                              ? Colors.white
                              : Color(0xFF391B4F), // Color(0xFFE997EE),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
