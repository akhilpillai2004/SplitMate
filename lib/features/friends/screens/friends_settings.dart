import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsSettingsScreen extends StatelessWidget {
  final String friendId;
  final String name;
  final String profilePic;
  final String email;

  const FriendsSettingsScreen({
    Key? key,
    required this.friendId,
    required this.name,
    required this.profilePic,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePic),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isNotEmpty ? email : 'N/A', // Ensure email fallback
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1, height: 30),
            const Text(
              'Manage Relationship',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text(
                'Remove from Friends List',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              leading: const Icon(Icons.remove_circle, color: Colors.red),
              onTap: () async {
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                if (currentUserId != null) {
                  // Remove the friend from the current user's friend list
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .update({
                    'friendsList': FieldValue.arrayRemove([friendId]), // Removing `friendId`
                  });

                  // Remove the current user from the friend's friend list
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(friendId)
                      .update({
                    'friendsList': FieldValue.arrayRemove([currentUserId]), // Removing `currentUserId`
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Friend removed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
