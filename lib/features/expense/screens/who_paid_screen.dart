// import 'package:flutter/material.dart';
// import 'package:split_mate/models/group_model.dart'; // Import your GroupModel
// import 'package:split_mate/models/user_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class WhoPaidScreen extends StatefulWidget {
//   final String? name; // Still accepting a string
//   final Function(String) onSelectionChanged;

//   const WhoPaidScreen({required this.name, required this.onSelectionChanged, Key? key})
//       : super(key: key);

//   @override
//   _WhoPaidScreenState createState() => _WhoPaidScreenState();
// }

// class _WhoPaidScreenState extends State<WhoPaidScreen> {
//   List<UserModel> memberList = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchGroupAndMembers();
//   }

//   void _fetchGroupAndMembers() async {
//     try {
//       // Fetch the GroupModel using the groupName
//       QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
//           .collection('groups')
//           .where('groupName', isEqualTo: widget.name)
//           .get();

//       if (groupSnapshot.docs.isEmpty) {
//         throw Exception('Group not found.');
//       }

//       // Convert the fetched group document to GroupModel
//       GroupModel group = GroupModel.fromMap(
//           groupSnapshot.docs.first.data() as Map<String, dynamic>);

//       // Fetch the member details using their UIDs
//       List<UserModel> members = [];
//       for (String memberId in group.members) {
//         DocumentSnapshot memberDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(memberId)
//             .get();
//         if (memberDoc.exists) {
//           members.add(UserModel.fromMap(memberDoc.data() as Map<String, dynamic>));
//         }
//       }

//       // Update state with fetched members
//       setState(() {
//         memberList = members;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error fetching group or members: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Who Paid?')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : memberList.isEmpty
//               ? const Center(child: Text('No members found.'))
//               : ListView.builder(
//                   itemCount: memberList.length,
//                   itemBuilder: (context, index) {
//                     UserModel member = memberList[index];
//                     return ListTile(
//                       title: Text(member.name),
//                       onTap: () {
//                         widget.onSelectionChanged(member.name);
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WhoPaidScreen extends StatefulWidget {
  final String mode; // Either "group" or "friend"
  final String? name; 
  final String? currentUserId; // Current user ID for "friend" mode
  //final UserModel? selectedFriend; // Selected friend for "friend" mode
  final Function(String) onSelectionChanged;

  const WhoPaidScreen({
    required this.mode,
    this.name,
    this.currentUserId,
    //this.selectedFriend,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  _WhoPaidScreenState createState() => _WhoPaidScreenState();
}

class _WhoPaidScreenState extends State<WhoPaidScreen> {
  List<UserModel> memberList = [];
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.mode == "group") {
      _fetchGroupAndMembers();
    } else if (widget.mode == "friend") {
      _fetchCurrentUser();
    }
  }

  // Fetch group members for "group" mode
  void _fetchGroupAndMembers() async {
    try {
      QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupName', isEqualTo: widget.name)
          .get();

      if (groupSnapshot.docs.isEmpty) {
        throw Exception('Group not found.');
      }

      GroupModel group = GroupModel.fromMap(
          groupSnapshot.docs.first.data() as Map<String, dynamic>);

      List<UserModel> members = [];
      for (String memberId in group.members) {
        DocumentSnapshot memberDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();
        if (memberDoc.exists) {
          members.add(UserModel.fromMap(memberDoc.data() as Map<String, dynamic>));
        }
      }

      setState(() {
        memberList = members;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching group or members: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch current user for "friend" mode
  void _fetchCurrentUser() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    if (userDoc.exists) {
      setState(() {
        currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        isLoading = false;
      });
    } else {
      throw Exception("Current user not found.");
    }
  } catch (e) {
    print("Error fetching current user: $e");
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Who Paid?')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.mode == "group" || widget.mode == 'group_face'
              ? _buildGroupList()
              : _buildFriendList(),
    );
  }

  // Build list for "group" mode
  // Build list for "group" mode with the current user included
Widget _buildGroupList() {
  if (memberList.isEmpty) {
    return const Center(child: Text('No members found.'));
  } else {
    // Include the current user in the list if it's not already present
    if (currentUser != null && !memberList.contains(currentUser)) {
      memberList.insert(0, currentUser!);
    }

    return ListView.builder(
      itemCount: memberList.length,
      itemBuilder: (context, index) {
        UserModel member = memberList[index];
        return ListTile(
          title: Text(member.name),
          onTap: () {
            widget.onSelectionChanged(member.name);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

  // Build list for "friend" mode
  Widget _buildFriendList() {
    return ListView(
      children: [
        // Current User
        ListTile(
          title: Text(currentUser?.name ?? 'You'),
          onTap: () {
            widget.onSelectionChanged(currentUser?.name ?? 'You');
            Navigator.pop(context);
          },
        ),
        // Selected Friend
        if (widget.name != null)
          ListTile(
            title: Text(widget.name!),
            onTap: () {
              widget.onSelectionChanged(widget.name!);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

