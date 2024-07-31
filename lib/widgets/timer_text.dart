import 'package:flutter/material.dart';

class TimerText extends StatelessWidget {
  final int duration;

  const TimerText(this.duration, {super.key});

  @override
  Widget build(BuildContext context) {
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
