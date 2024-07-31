enum CameraPermission {
  authorized,
  denied,
  unknown,
}

extension CameraPermissionX on CameraPermission {
  static CameraPermission fromString(String value) {
    switch (value) {
      case 'authorized':
        return CameraPermission.authorized;
      case 'denied':
        return CameraPermission.denied;
      case 'unknown':
        return CameraPermission.unknown;
      default:
        return CameraPermission.unknown;
    }
  }
}
