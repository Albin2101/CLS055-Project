import 'package:dawnfighter/views/ar_view.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Hello User')),
      floatingActionButton: ARviewButton(context),
    );
  }
}

Widget ARviewButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppArView()),
      );
    },
    child: const Text('Go to AR View'),
  );
}
