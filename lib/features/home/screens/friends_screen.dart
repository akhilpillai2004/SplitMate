import 'package:flutter/material.dart';
import 'package:split_mate/features/expense/screens/add_expense_screen.dart';
import 'package:split_mate/features/friends/screens/add_friends.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split_mate/features/friends/screens/friend_face_screen.dart';
import 'package:split_mate/models/user_model.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<UserModel> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return;
    }

    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final doc = await currentUserRef.get();

    if (doc.exists) {
      List<String> friendsIds =
          List<String>.from(doc.data()?['friendsList'] ?? []);
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: friendsIds)
          .get();

      setState(() {
        _friendsList = friendsSnapshot.docs.map((doc) {
          return UserModel.fromMap({
            'username': doc['username'],
            'name': doc['name'],
            'profilePic': doc['profilePic'],
            'uid': doc.id,
            'isAuthenticated': doc['isAuthenticated'],
            //'splitBalance': doc['splitBalance'],
            'friendsList': List<String>.from(doc['friendsList'] ?? []),
            'email': doc['email'],
          });
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _friendsList.isEmpty
                ? Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFriendsScreen(),
                          ),
                        ).then((_) => _loadFriends());
                      },
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        'Add Friend',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(170, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount:
                        _friendsList.length + 1, // Add one for the button
                    itemBuilder: (context, index) {
                      if (index < _friendsList.length) {
                        final friend = _friendsList[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(friend.profilePic),
                              radius:
                                  30, // Adjust the size of the profile picture
                            ),
                            title: Text(
                              friend.name,
                              style: const TextStyle(
                                fontSize: 18, // Increase font size for the name
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendFaceScreen(
                                    friendId: friend.uid,
                                    name: friend.name,
                                    profilePic: friend.profilePic,
                                    email: friend.email,
                                    preSelectedUser: friend,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddFriendsScreen(),
                                  ),
                                ).then((_) => _loadFriends());
                              },
                              icon: const Icon(Icons.person_add,
                                  color: Colors.white),
                              label: const Text(
                                'Add More Friends',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(170, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Navigate to AddExpenseScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(
                mode: 'friend',
               // onSelectionChanged: (selectedName) => print('Selected: $selectedName'),

              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Set button background color
          onPrimary: Colors.white, // Set text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 22, vertical: 15), // Padding for the button
        ),
        child: const Text(
          'Add Expense',
          style: TextStyle(
            fontSize: 16, // Font size for the button text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
