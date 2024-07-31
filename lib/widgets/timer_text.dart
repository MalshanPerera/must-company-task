import 'package:flutter/material.dart';

import '../utils/utils.dart';

class TimerText extends StatelessWidget {
  final int duration;

  const TimerText(this.duration, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(duration),
      style: const TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
