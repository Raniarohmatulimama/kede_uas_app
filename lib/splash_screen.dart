import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'welcome_screen.dart';
import 'providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentDot = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load user data from SharedPreferences FIRST (await)
    await Provider.of<UserProvider>(context, listen: false).loadUserData();

    // Timer for dot animation
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _currentDot = (_currentDot + 1) % 3;
        });
      }
    });

    // Timer for navigation (wait 3 seconds then navigate)
    Timer(const Duration(seconds: 3), () {
      _dotTimer?.cancel();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF52B74A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo-icon.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Image.asset('assets/images/logo-text-dark.png', height: 60),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(0),
                const SizedBox(width: 8),
                _buildDot(1),
                const SizedBox(width: 8),
                _buildDot(2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: index == _currentDot ? Colors.white : const Color(0xFF52B74A),
        shape: BoxShape.circle,
      ),
    );
  }
}
