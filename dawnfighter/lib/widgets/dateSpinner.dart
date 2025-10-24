import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class DateSpinner extends StatefulWidget {
  final Function(DateTime) onTimeChanged;
  final DateTime? initialTime;

  const DateSpinner({super.key, required this.onTimeChanged, this.initialTime});

  @override
  _DateSpinnerState createState() => _DateSpinnerState();
}

class _DateSpinnerState extends State<DateSpinner> {
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _dateTime = widget.initialTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[_timeSpinner(), const SizedBox(height: 16)],
      ),
    );
  }

  Widget _timeSpinner() {
    return TimePickerSpinner(
      alignment: Alignment.center,
      is24HourMode: true,
      time: _dateTime,
      normalTextStyle: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 30,
        color: Color(0xFFE997EE),
      ),
      highlightedTextStyle: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 39,
        color: Colors.white,
      ),
      spacing: 20,
      itemHeight: 60,
      itemWidth: 80,
      isForce2Digits: true,
      minutesInterval: 1,
      onTimeChange: (time) {
        setState(() {
          _dateTime = time;
        });
        widget.onTimeChanged(time);
      },
    );
  }
}
