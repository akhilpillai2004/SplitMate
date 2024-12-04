import 'package:flutter/material.dart';
import 'package:split_mate/features/auth/screens/welcome_screen.dart'; // Import WelcomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // Total duration for both animations
      vsync: this,
    );

    // Logo fade animation: Fade out
    _logoFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Text fade animation: Fade in after the logo fades out
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startSplashScreen();
  }

  // Start the animation and navigate to the login screen after the animation completes
  _startSplashScreen() {
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Logo fade transition
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: Image.asset(
                'assets/images/logo.png',  // Ensure this path is correct
                height: 150,  // Make the logo bigger
              ),
            ),
            // Text fade transition, appears after the logo fades out
            FadeTransition(
              opacity: _textFadeAnimation,
              child: const Text(
                'Welcome to SplitMate',
                style: TextStyle(
                  fontSize: 32, // Larger text size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
