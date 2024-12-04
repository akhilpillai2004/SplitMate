import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_mate/features/auth/controller/auth_controller.dart';
import 'package:split_mate/features/auth/screens/welcome_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userModel == null
            ? const Center(
                child: Text(
                  'No user information available.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userModel.profilePic),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userModel.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4), // Space between name and email
                          Text(
                            userModel.email,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black), // Black color for email
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () async {
                      // Show confirmation dialog before logging out
                      bool confirmLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      ) ?? false;

                      // If user confirms, perform logout and navigate to Welcome screen
                      if (confirmLogout) {
                        ref.read(authControllerProvider.notifier).logout(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red, // Red icon color
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red), // Red text color
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
