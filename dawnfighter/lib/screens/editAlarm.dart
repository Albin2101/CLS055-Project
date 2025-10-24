import 'package:flutter/material.dart';
import '../widgets/dateSpinner.dart';

class EditAlarm extends StatefulWidget {
  final DateTime? initialTime;
  final List<bool>? initialDays;
  final bool isNew;

  const EditAlarm({
    super.key,
    this.initialTime,
    this.initialDays,
    this.isNew = false,
  });

  @override
  State<EditAlarm> createState() => _EditAlarmState();
}

class _EditAlarmState extends State<EditAlarm> {
  late DateTime _selectedTime;
  late List<bool> _days;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedTime =
        widget.initialTime ??
        (widget.isNew
            ? DateTime(
                now.year,
                now.month,
                now.day,
                8,
                0,
              ) // default to 08:00 for new alarms
            : now);
    // clone incoming list so we don't mutate the parent's list directly
    _days = widget.initialDays != null
        ? List<bool>.from(widget.initialDays!)
        : [false, false, false, false, false, false, false];
  }

  void _save() {
    final normalized = DateTime(
      _selectedTime.year,
      _selectedTime.month,
      _selectedTime.day,
      _selectedTime.hour,
      _selectedTime.minute,
      0,
    );
    // return a cloned list to avoid accidental shared mutation
    Navigator.pop(context, {
      'time': normalized,
      'days': List<bool>.from(_days),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 90),
              Text(
                widget.isNew ? 'ADD\nALARM' : 'EDIT\nALARM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 90),

              DateSpinner(
                initialTime: _selectedTime,
                onTimeChanged: (time) {
                  setState(() => _selectedTime = time);
                },
              ),

              const SizedBox(height: 30),

              Container(
                alignment: Alignment.center,
                height: 88,
                width: 321,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    alignment: AlignmentGeometry.topCenter,
                    image: AssetImage('assets/images/alarmCard.png'),
                    fit: BoxFit.fill,
                  ),
                ),

                child: Wrap(
                  spacing: 10,
                  runSpacing: 0,
                  children: List.generate(7, (index) {
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isSelected = _days[index];

                    return RawChip(
                      label: Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF391B4F),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _days[index] = val),
                      showCheckmark: false,
                      selectedColor: const Color(0xFF391B4F),

                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pressElevation: 0,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide.none,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),

          // Bottom bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 88,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  alignment: AlignmentGeometry.topCenter,
                  image: AssetImage('assets/images/editBar.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(),
                      ),
                      onPressed: () {
                        // Cancel -> return null so parent does not apply changes
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE997EE),
                        ),
                      ),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(),
                      ),
                      onPressed: () {
                        _save();
                      },
                      child: Text(
                        'Save',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
