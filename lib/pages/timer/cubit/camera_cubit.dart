import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../services/camera_service.dart';
import '../../../utils/enums.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraService cameraService;

  CameraCubit({
    required this.cameraService,
  }) : super(const CameraInitial()) {
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    final status = await cameraService.checkCameraPermission();
    if (status == CameraPermission.denied) {
      emit(const CameraDenied());
    } else if (status == CameraPermission.unknown) {
      emit(const CameraUnknown());
    } else {
      emit(const CameraAuthorized());
      await cameraService.initCamera();
    }
  }

  Future<void> captureImage() async {
    if (state.permissionStatus == CameraPermission.authorized) {
      final path = await cameraService.takePicture();
      await cameraService.closeCamera();
      emit(CameraImageCaptured(path));
    }
  }

  void resetImage() {
    emit(const CameraImageClear());
  }

  @override
  Future<void> close() {
    cameraService.closeCamera();
    return super.close();
  }
}
