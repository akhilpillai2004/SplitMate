import 'package:flutter/material.dart';
import 'package:split_mate/core/common/sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Setting the background color to white
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Section (Logo and Title)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // Center the content vertically
                crossAxisAlignment: CrossAxisAlignment.center,  // Center the content horizontally
                children: <Widget>[
                  // Logo Section
                  Image.asset(
                    'assets/images/logo.png',  // Ensure this path is correct
                    height: 120,  // Set the height for the logo
                  ),
                  const SizedBox(height: 20),  // Add some space below the logo

                  // Title Section
                  const Text(
                    'SplitMate',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),  // Add some space below the title
                ],
              ),
            ),

            // Bottom Section (Buttons)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),  // Add some space from the bottom
              child: Column(
                children: <Widget>[
                  // Sign Up Button with Padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,  // Green background color
                        minimumSize: const Size(double.infinity, 50),
                        shape: const RoundedRectangleBorder(),  // Rectangle shape
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
                  const SizedBox(height: 10,),
                  // Log In Button with Padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,  // Blue background color for Log In
                        minimumSize: const Size(double.infinity, 50),
                        shape: const RoundedRectangleBorder(),  // Rectangle shape
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

                  // Continue with Google Button
                  const SignInButton(),  // Your custom Google Sign In Button widget
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
