import 'package:flutter/material.dart';
import 'package:split_mate/features/home/screens/home_screen.dart';

class PreHomeScreen extends StatelessWidget {
  const PreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false, // Remove back button
      //   centerTitle: true, // Center the title in the app bar
      // ),
      
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0, bottom: 100.0,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // Align content to the left
          children: [
            // "Let's get started!" aligned to top left
            const Text(
              'Let\'s get started!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left, // Align text to the left
            ),
            const SizedBox(height: 20),

            // "What would you like to do first?" aligned to top left
            const Text(
              'What would you like to do first?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),

            // Centered buttons for "Add a group trip" and "Add your apartment"
            Expanded(  // Use Expanded to fill remaining space and vertically center buttons
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // Vertically center buttons and skip button
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your navigation or logic here
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AddGroupTripScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      minimumSize: const Size(double.infinity, 50), // Full-width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Make the button rounded
                      ),
                    ),
                    child: const Text(
                      'Add a Group Trip',
                      style: TextStyle(fontSize: 18, color: Colors.white,),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () {
                      // Add your navigation or logic here
                      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => AddApartmentScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                      minimumSize: const Size(double.infinity, 50), // Full-width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Make the button rounded
                      ),
                    ),
                    child: const Text(
                      'Add Your Apartment',
                      style: TextStyle(fontSize: 18, color: Colors.white,),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // "Skip" button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(), // Ensure LoginScreen is properly imported
                          ),
                        );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue, // Color for skip button text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//         centerTitle: true,
//       ),
//       body: const Center(
//         child: Text('Welcome to the Home Screen'),
//       ),
//     );
//   }
// }
