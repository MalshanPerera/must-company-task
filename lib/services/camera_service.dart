import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/enums.dart';

class CameraService {
  final MethodChannel _channel = const MethodChannel('camera_macos');

  Future<CameraPermission> checkCameraPermission() async {
    try {
      final String permission = await _channel.invokeMethod('checkPermission');
      return CameraPermissionX.fromString(permission);
    } on PlatformException catch (e) {
      debugPrint('Error getting camera permission: ${e.message}');
      return CameraPermission.unknown;
    }
  }

  Future<void> initCamera() async {
    try {
      await _channel.invokeMethod('initCamera');
    } on PlatformException catch (e) {
      debugPrint('Error opening camera: ${e.message}');
    }
  }

  Future<String> takePicture() async {
    try {
      final String path = await _channel.invokeMethod('takePicture');
      debugPrint('Picture saved to: $path');

      return path;
    } on PlatformException catch (e) {
      debugPrint('Error taking picture: ${e.message}');
      return "";
    }
  }

  Future<void> closeCamera() async {
    try {
      await _channel.invokeMethod('closeCamera');
    } on PlatformException catch (e) {
      debugPrint('Error closing camera: ${e.message}');
    }
  }
}
