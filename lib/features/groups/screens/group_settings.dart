import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:split_mate/features/groups/screens/add_members.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/models/user_model.dart';

class GroupSettingsScreen extends StatefulWidget {
  final GroupModel group;

  const GroupSettingsScreen({Key? key, required this.group}) : super(key: key);

  @override
  _GroupSettingsScreenState createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late TextEditingController _groupNameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.groupName);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _updateGroupName() async {
    setState(() {
      widget.group.groupName = _groupNameController.text;
      _isEditingName = false;
    });

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.groupId)
          .update({'groupName': widget.group.groupName});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update group name')),
      );
      print('Error updating group name: $e');
    }
  }

  Future<void> _leaveGroup() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently signed in.')),
      );
      return;
    }

    if (currentUserId == widget.group.creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('The group creator cannot leave the group.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.groupId)
          .update({
        'members': FieldValue.arrayRemove([currentUserId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the group.')),
      );

      setState(() {
        widget.group.members.remove(currentUserId);
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave the group')),
      );
      print('Error leaving group: $e');
    }
  }

  Future<void> _deleteGroup() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId != widget.group.creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only the creator can delete the group.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.groupId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group deleted successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the group')),
      );
      print('Error deleting group: $e');
    }
  }

  Future<void> _toggleAdminStatus(String userId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId != widget.group.creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Only the group creator can change admin status.')),
      );
      return;
    }

    bool isAdmin = widget.group.adminStatus[userId] ?? false;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.groupId)
          .update({
        'adminStatus.$userId': !isAdmin,
      });

      setState(() {
        widget.group.adminStatus[userId] = !isAdmin;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAdmin ? 'Admin removed' : 'Admin added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change admin status')),
      );
      print('Error toggling admin status: $e');
    }
  }

  Future<void> _removeMember(String userId) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId != widget.group.creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Only the group creator can remove members.')),
      );
      return;
    }

    if (userId == widget.group.creatorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The creator cannot be removed.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.groupId)
          .update({
        'members': FieldValue.arrayRemove([userId])
      });

      setState(() {
        widget.group.members.remove(userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove member')),
      );
      print('Error removing member: $e');
    }
  }

  Future<String> _getUserNameByUid(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        UserModel user =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        return user.name;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'Error';
    }
  }

  Future<void> _addMembers() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(group: widget.group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.group.groupIcon),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        _isEditingName
                            ? Expanded(
                                child: TextField(
                                  controller: _groupNameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Edit group name',
                                  ),
                                ),
                              )
                            : Text(
                                widget.group.groupName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditingName = !_isEditingName;
                            });
                            if (!_isEditingName) {
                              _updateGroupName();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, thickness: 0.5, height: 20),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.group_add, color: Colors.blue),
                title: const Text('Add Members'),
                onTap: _addMembers,
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 0.5, height: 20),
              Text('Members', style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.group.members.length,
                itemBuilder: (context, index) {
                  String memberId = widget.group.members[index];
                  return FutureBuilder<String>(
                    future: _getUserNameByUid(memberId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const ListTile(
                            title: Text('Error fetching member name'));
                      }

                      String memberName = snapshot.data ?? 'Unknown';
                      bool isAdmin =
                          widget.group.adminStatus[memberId] ?? false;
                      bool isCreator = memberId == widget.group.creatorId;

                      return ListTile(
                        title: Text(memberName),
                        subtitle: (isAdmin || isCreator)
                            ? const Text('Admin',
                                style: TextStyle(color: Colors.blue))
                            : null,
                        trailing:
                            memberId != FirebaseAuth.instance.currentUser?.uid
                                ? PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'remove') {
                                        _removeMember(memberId);
                                      } else if (value == 'toggleAdmin') {
                                        _toggleAdminStatus(memberId);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'toggleAdmin',
                                        child: Text('Make/Remove Admin'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'remove',
                                        child: Text('Remove Member'),
                                      ),
                                    ],
                                  )
                                : null,
                      );
                    },
                  );
                },
              ),
              const Divider(color: Colors.grey, thickness: 0.5, height: 20),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Leave Group', style: TextStyle(color: Colors.red)),
                onTap: _leaveGroup,
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title:
                    Text('Delete Group', style: TextStyle(color: Colors.red)),
                onTap: _deleteGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
