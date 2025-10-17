import 'package:dawnfighter/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/homescreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Homescreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
