import 'package:flutter/material.dart';
import 'package:split_mate/features/auth/screens/login_screen.dart'; // Import LoginScreen
import 'package:split_mate/core/common/sign_in_button.dart';
import 'package:split_mate/features/auth/screens/sign_up_screen.dart'; // Your custom Google Sign In Button widget

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png', // Ensure this path is correct
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SplitMate',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: <Widget>[
                  // Sign Up Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(), // Ensure LoginScreen is properly imported
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Green background color
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Log In Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to LoginScreen when clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(), // Ensure LoginScreen is properly imported
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // White background color for Log In
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  //const SizedBox(height: 10),

                  // Continue with Google Button
                  const SignInButton(), // Your custom Google Sign In Button widget
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
