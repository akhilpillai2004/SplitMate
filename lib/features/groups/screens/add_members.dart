import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/models/user_model.dart';

class AddMembersScreen extends StatefulWidget {
  final GroupModel group;

  const AddMembersScreen({Key? key, required this.group}) : super(key: key);

  @override
  _AddMembersScreenState createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final TextEditingController _emailController = TextEditingController();
  final List<UserModel> _addedMembers = [];
  List<UserModel> _suggestedUsers = [];

  Future<void> _addMember(UserModel member) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return; // Handle unauthenticated user
    }

    final groupRef = FirebaseFirestore.instance.collection('groups').doc(widget.group.groupId);
    final groupDoc = await groupRef.get();
    List<String> currentGroupMembers = List<String>.from(groupDoc.data()?['members'] ?? []);

    if (currentGroupMembers.contains(member.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member already added!')),
      );
      return;
    }

    try {
      await groupRef.update({
        'members': FieldValue.arrayUnion([member.uid]), // Add member's uid
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member added successfully!')),
      );

      setState(() {
        _addedMembers.add(member); // Update UI
        _suggestedUsers.clear(); // Clear suggestions after adding
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member: $e')),
      );
    }
  }

  void _searchUsersByEmail(String email) async {
    if (email.isNotEmpty) {
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      setState(() {
        _suggestedUsers = userQuery.docs.map((doc) {
          return UserModel.fromMap({
            'uid': doc['uid'],
            'email': doc['email'],
            'name': doc['name'],
          });
        }).toList();
      });
    } else {
      setState(() {
        _suggestedUsers.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _emailController,
              onChanged: _searchUsersByEmail,
              decoration: const InputDecoration(
                labelText: 'Enter member email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_suggestedUsers.isNotEmpty) 
            Expanded(
              child: ListView.builder(
                itemCount: _suggestedUsers.length,
                itemBuilder: (context, index) {
                  final user = _suggestedUsers[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    onTap: () async {
                      await _addMember(user);
                    },
                    title: Text(
                      user.name,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.email),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
