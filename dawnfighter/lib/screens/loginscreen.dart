import 'package:flutter/material.dart';
import '../widgets/loginCard.dart';

class LoginTestScreen extends StatefulWidget {
  const LoginTestScreen({super.key});

  @override
  State<LoginTestScreen> createState() => _LoginTestScreenState();
}

class _LoginTestScreenState extends State<LoginTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'DAWNFIGHTER AR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 80),
                    const Text(
                      'LOG IN',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 30),

                    LoginCard(width: 320, height: 220),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
