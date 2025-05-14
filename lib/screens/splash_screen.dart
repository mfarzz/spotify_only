import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_only/services/auth_service.dart';
import 'package:spotify_only/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Add a small delay for a better user experience
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Check if user is already authenticated using AuthService
      if (AuthService().currentUser != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/spotify_logo.png',
              height: 100,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
            ),
          ],
        ),
      ),
    );
  }
}