part of 'camera_cubit.dart';

sealed class CameraState extends Equatable {
  final CameraPermission permissionStatus;
  final String imagePath;
  const CameraState(this.permissionStatus, this.imagePath);

  @override
  List<Object> get props => [permissionStatus, imagePath];
}

final class CameraInitial extends CameraState {
  const CameraInitial() : super(CameraPermission.unknown, '');
}

final class CameraAuthorized extends CameraState {
  const CameraAuthorized() : super(CameraPermission.authorized, '');
}

final class CameraDenied extends CameraState {
  const CameraDenied() : super(CameraPermission.denied, '');
}

final class CameraUnknown extends CameraState {
  const CameraUnknown() : super(CameraPermission.unknown, '');
}

final class CameraImageCaptured extends CameraState {
  const CameraImageCaptured(String imagePath)
      : super(CameraPermission.authorized, imagePath);
}

final class CameraImageClear extends CameraState {
  const CameraImageClear() : super(CameraPermission.authorized, '');
}
