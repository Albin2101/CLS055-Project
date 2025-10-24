import 'package:flutter/material.dart';

class AlarmCard extends StatefulWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final List<bool> days;
  final bool showDelete;
  final VoidCallback onCancelDelete;

  const AlarmCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    required this.days,
    this.showDelete = false,
    required this.onCancelDelete,
  });

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.showDelete) {
          widget.onCancelDelete();
          return;
        }
        widget.onTap();
      },
      onLongPress: () {
        widget.onLongPress();
      },
      child: Container(
        width: 320,
        height: 120,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/alarmCard.png'),
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
        child: widget.showDelete
            ? Center(
                child: TextButton(
                  onPressed: widget.onDelete,
                  child: Text(
                    'DELETE',
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Padding(
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
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            color: widget.value
                                ? Colors.white
                                : const Color(0xFF391B4F),
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(7, (index) {
                            final day = [
                              'M',
                              'T',
                              'W',
                              'T',
                              'F',
                              'S',
                              'S',
                            ][index];
                            final isActive = widget.days[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF391B4F),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    Switch(
                      value: widget.value,
                      onChanged: widget.onChanged,
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
