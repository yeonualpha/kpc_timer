import 'package:flutter/material.dart';
import 'package:kpc_timer/screens/screen_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kpc_timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TimerScreen(),
    );
  }
}
