import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/timer/bloc/timer_bloc.dart';
import '../pages/timer/timer_page.dart';
import 'constants.dart';
import 'ticker.dart';

Route<dynamic>? routes(RouteSettings settings) {
  switch (settings.name) {
    case kInitialRoute:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => TimerBloc(ticker: const Ticker()),
          child: const TimerPage(),
        ),
      );
    default:
      return null;
  }
}
