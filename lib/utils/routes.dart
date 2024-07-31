import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/timer/cubit/camera_cubit.dart';
import '../pages/timer/time_bloc/timer_bloc.dart';
import '../pages/timer/timer_page.dart';
import '../services/camera_service.dart';
import 'constants.dart';
import 'ticker.dart';

Route<dynamic>? routes(RouteSettings settings) {
  switch (settings.name) {
    case kInitialRoute:
      return MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => TimerBloc(
                ticker: const Ticker(),
              ),
            ),
            BlocProvider(
              create: (context) => CameraCubit(
                cameraService: CameraService(),
              ),
            ),
          ],
          child: const TimerPage(),
        ),
      );
    default:
      return null;
  }
}
