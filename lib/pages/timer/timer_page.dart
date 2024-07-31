import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';

import '../../services/camera_service.dart';
import '../../utils/utils.dart';
import '../../widgets/timer_text.dart';
import 'cubit/camera_cubit.dart';
import 'time_bloc/timer_bloc.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final camera = CameraService();
  late ScreenshotController _screenshotController;

  @override
  void initState() {
    super.initState();
    _screenshotController = ScreenshotController();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Timer'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocConsumer<CameraCubit, CameraState>(
              listener: (context, state) {
                if (state is CameraImageCaptured) {
                  _takeScreenshot();
                }
                if (state is CameraDenied) {
                  _showToast("Camera permission denied");
                }
                if (state is CameraUnknown) {
                  _showToast("Error checking camera permission");
                }
              },
              builder: (context, state) {
                return state.imagePath != ""
                    ? Image.asset(
                        state.imagePath,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox.shrink();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Center(
                child: BlocConsumer<TimerBloc, TimerState>(
                  listener: (context, state) async {
                    if (state.duration == 0) {
                      await context.read<CameraCubit>().captureImage();
                    }
                  },
                  builder: (context, state) {
                    return BlocBuilder<TimerBloc, TimerState>(
                      builder: (context, state) {
                        final duration = state.duration;
                        return TimerText(duration);
                      },
                    );
                  },
                ),
              ),
            ),
            const ButtonActions(),
          ],
        ),
      ),
    );
  }

  void _takeScreenshot() async {
    final isSuccess = await captureAndSavePng(
      controller: _screenshotController,
    );

    if (isSuccess) {
      _showToast("Screenshot saved to Downloads");
    } else {
      _showToast("Screenshot saved to Downloads");
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class ButtonActions extends StatelessWidget {
  const ButtonActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...switch (state) {
              TimerInitial() => [
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () => context
                        .read<TimerBloc>()
                        .add(TimerStarted(duration: state.duration)),
                  ),
                ],
              TimerRunInProgress() => [
                  FloatingActionButton(
                    child: const Icon(Icons.pause),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerPaused()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () {
                      context.read<CameraCubit>().resetImage();
                      context.read<TimerBloc>().add(const TimerReset());
                    },
                  ),
                ],
              TimerRunPause() => [
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerResumed()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () {
                      context.read<CameraCubit>().resetImage();
                      context.read<TimerBloc>().add(const TimerReset());
                    },
                  ),
                ],
              TimerRunComplete() => [
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () {
                      context.read<CameraCubit>().resetImage();
                      context.read<TimerBloc>().add(const TimerReset());
                    },
                  ),
                ]
            }
          ],
        );
      },
    );
  }
}
