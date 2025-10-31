import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

typedef OnCreateSuccess = void Function(String uid);

class CreateAccountCard extends StatefulWidget {
  final double width;
  final double height;
  final OnCreateSuccess? onSuccess;

  const CreateAccountCard({
    super.key,
    this.width = 320,
    this.height = 260,
    this.onSuccess,
  });

  @override
  State<CreateAccountCard> createState() => _CreateAccountCardState();
}

class _CreateAccountCardState extends State<CreateAccountCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;


    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter name, email & password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      
      if (uid == null) throw Exception('Failed to obtain user id');

      try {
        final userData = {
          'name': name,
          'points': 0,
          'streak': 0,
          'monsters': 0,
          // use server timestamp to avoid sending complex DateTime objects
          'createdAt': FieldValue.serverTimestamp(),
        };
        await FirestoreService.setUserData(uid, userData);

        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Account created: $uid')));
        widget.onSuccess?.call(uid);
        return;
      } catch (e) {
        
        if (!mounted) return;
        setState(() => _isLoading = false);
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Database error'),
            content: Text('Failed to save user data: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save user data: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/loginCard.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.white.withValues(),
              ),
              decoration: InputDecoration(
                hintText: 'Display Name',
                hintStyle: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                    color: Color(0xFFE997EE),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xA0E997EE)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE997EE)),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.white.withValues(),
              ),
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                    color: Color(0xFFE997EE),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xA0E997EE)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE997EE)),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.white.withValues(),
              ),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                    color: Color(0xFFE997EE),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xA0E997EE)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE997EE)),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 140,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF391B4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: _isLoading ? null : _createAccount,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(
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
    );
  }
}
