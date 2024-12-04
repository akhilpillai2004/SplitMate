import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split_mate/models/user_model.dart';

class AddFriendsScreen extends StatefulWidget {
  @override
  _AddFriendsScreenState createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = []; // Search results list
  List<UserModel> _addedFriends = []; // List of added friends

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchUsers); // Listen for changes in the search bar
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // Query users by username, email, or name
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs.map((doc) {
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

  Future<void> _addFriend(UserModel friend) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      // Handle the case where the user is not authenticated
      return;
    }

    // Reference the current user's document in Firestore
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    // Check if the friend is already in the current user's friend list
    final currentUserDoc = await currentUserRef.get();
    List<String> currentUserFriends = List<String>.from(currentUserDoc.data()?['friendsList'] ?? []);

    if (currentUserFriends.contains(friend.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend already added!')),
      );
      return;
    }

    // Add the friend's user ID to the current user's friends list
    await currentUserRef.update({
      'friendsList': FieldValue.arrayUnion([friend.uid]),
    });

    // Add current user's ID to the friend's friend list
    final friendRef = FirebaseFirestore.instance.collection('users').doc(friend.uid);
    await friendRef.update({
      'friendsList': FieldValue.arrayUnion([currentUserId]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend added successfully!')),
    );

    setState(() {
      _addedFriends.add(friend);
      _searchResults.clear();
    });

    // Optionally navigate back to the previous screen after adding a friend
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by username, name, or email',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        // Call the function to add a friend when clicked
                        await _addFriend(user);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
