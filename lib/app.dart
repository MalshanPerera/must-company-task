import 'package:flutter/material.dart';

import 'design/theme.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: kInitialRoute,
      onGenerateRoute: routes,
    );
  }
}
