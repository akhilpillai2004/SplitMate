import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_mate/core/constants/constants.dart';
import 'package:split_mate/core/utils.dart';
import 'package:split_mate/features/groups/controller/group_controller.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class CreateGroupsScreen extends ConsumerStatefulWidget {
  const CreateGroupsScreen({super.key});

  @override
  ConsumerState<CreateGroupsScreen> createState() => _CreateGroupsScreenState();
}

class _CreateGroupsScreenState extends ConsumerState<CreateGroupsScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      showSnackBar(context, 'Group name cannot be empty.');
      return;
    }

    final groupId = Uuid().v4(); // Generate a unique group ID
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      showSnackBar(context, 'You must be logged in to create a group.');
      return;
    }

    final userId = currentUser.uid; // Retrieve the current user's ID

    // Create a map to keep track of admin statuses (initially set the creator as an admin)
    final adminStatus = <String, bool> {
      userId: true, // The creator is marked as an admin
    };

    final newGroup = GroupModel(
      groupId: groupId,
      groupName: groupName,
      groupIcon: Constants.avatarDefault, // Placeholder for group icon
      creatorId: userId,
      members: [userId], // Add the creator as the initial member
      adminStatus: adminStatus, // Add admin status map
      totalBalance: 0.0,
    );

    final controller = ref.read(groupControllerProvider.notifier);

    try {
      await controller.createGroup(context, newGroup);
      showSnackBar(context, 'Group created successfully!');
      Navigator.pop(context); // Navigate back after creating the group
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      showSnackBar(context, 'Platform error: ${e.message ?? 'An error occurred.'}');
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific exceptions
      String errorMessage;
      switch (e.code) {
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        case 'user-not-found':
          errorMessage = 'User not found. Please ensure you are logged in.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      showSnackBar(context, errorMessage);
    } catch (e) {
      // Handle any other exceptions
      showSnackBar(context, 'An unexpected error occurred. Please try again.');
    }
  }
}
