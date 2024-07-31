import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pages/timer/bloc/timer_bloc.dart';
import 'pages/timer/timer_page.dart';
import 'utils/ticker.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Must Company Task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => BlocProvider(
              create: (_) => TimerBloc(ticker: const Ticker()),
              child: const TimerPage(),
            ),
      },
    );
  }
}
