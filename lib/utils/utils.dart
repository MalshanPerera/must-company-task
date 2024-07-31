import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

String formatDuration(int durationInSeconds) {
  final hours = (durationInSeconds / 3600).floor();
  final minutes = ((durationInSeconds % 3600) / 60).floor();
  final seconds = (durationInSeconds % 60).floor();

  final hoursStr = hours.toString().padLeft(2, '0');
  final minutesStr = minutes.toString().padLeft(2, '0');
  final secondsStr = seconds.toString().padLeft(2, '0');

  return '$hoursStr:$minutesStr:$secondsStr';
}

Future<bool> captureAndSavePng({
  required ScreenshotController controller,
  Duration delay = const Duration(seconds: 1),
}) async {
  try {
    final Directory? directory = await getDownloadsDirectory();
    if (directory == null) {
      debugPrint('Could not access the Downloads directory');
      return false;
    }

    final fileName = 'screenshot_${DateTime.now()}.png';
    final screenshotPath = '${directory.path}/$fileName';

    final Uint8List? image = await controller.capture(delay: delay);
    if (image != null) {
      final imagePath = await File(screenshotPath).create();
      await imagePath.writeAsBytes(image);

      debugPrint('Screenshot saved to $screenshotPath');
      return true;
    }

    return false;
  } catch (e) {
    debugPrint('Error capturing and saving screenshot: $e');
    return false;
  }
}
