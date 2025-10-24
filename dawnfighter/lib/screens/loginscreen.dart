import 'package:flutter/material.dart';
import '../widgets/loginCard.dart';
import '../widgets/createAccountCard.dart';

class LoginTestScreen extends StatefulWidget {
  const LoginTestScreen({super.key});

  @override
  State<LoginTestScreen> createState() => _LoginTestScreenState();
}

class _LoginTestScreenState extends State<LoginTestScreen> {
  bool _showCreate = false;

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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'DAWNFIGHTER AR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    SizedBox(height:64),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    SizedBox(height:24),
                    // show either the login card or the create-account card in the same slot
                    // keep the slot a fixed height so the title above doesn't shift when
                    // a taller card (create-account) is shown — extra space is below the card
                    SizedBox(
                      height: 260,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 0),
                          child: _showCreate
                              ? SizedBox(
                                  key: const ValueKey('create'),
                                  width: 320,
                                  height: 260,
                                  child: CreateAccountCard(
                                    width: 320,
                                    height: 260,
                                    onSuccess: (uid) async {
                                      // Show a confirmation dialog with the UID so the user sees
                                      // the result; then hide the create form.
                                      if (!mounted) return;
                                      await showDialog<void>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Account created'),
                                          content: Text('User id: $uid'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (!mounted) return;
                                      setState(() => _showCreate = false);
                                    },
                                  ),
                                )
                              : SizedBox(
                                  key: const ValueKey('login'),
                                  width: 320,
                                  height: 220,
                                  child: LoginCard(width: 320, height: 220),
                                ),
                        ),
                      ),
                    ),

                    // Hint text above create account (hidden when create form visible)
                    if (!_showCreate) ...[
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),  
                              blurRadius: 3.0,           
                              color: Color(0x55391B4F),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                    ],

                    // Create account CTA (toggle which card is shown) — sized to content
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF391B4F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () =>
                            setState(() => _showCreate = !_showCreate),
                        child: Text(
                          _showCreate ? 'Cancel' : 'Create account',
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
