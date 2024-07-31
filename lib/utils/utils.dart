import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

Future<bool> captureAndSavePng({
  required ScreenshotController controller,
}) async {
  try {
    final Directory? appDocDir = await getDownloadsDirectory();
    if (appDocDir == null) {
      debugPrint('Could not access the Downloads directory');
      return false;
    }

    final fileName = 'screenshot_${DateTime.now().toIso8601String()}.png';
    final screenshotPath = '${appDocDir.path}/$fileName';

    await controller.captureAndSave(
      screenshotPath,
      fileName: fileName,
    );

    debugPrint('Screenshot saved to $screenshotPath');
    return true;
  } catch (e) {
    debugPrint('Error capturing and saving screenshot: $e');
    return false;
  }
}
