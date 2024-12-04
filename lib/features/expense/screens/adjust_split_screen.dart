import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:split_mate/models/group_model.dart';
import 'package:split_mate/models/user_model.dart';

class AdjustSplitScreen extends StatefulWidget {
  final String? name; // Accepts the name of the group or friend's name
  final String mode; // Mode can be 'group' or 'friend'
  final double? amount;
  final String? currentUserId; // Amount for the split (used in 'friend' mode)
  //final Function(List<UserModel>) onSelectionChanged; // Updated callback to accept a list of UserModel

  const AdjustSplitScreen({
    required this.name,
    required this.mode,
    this.amount,
    this.currentUserId,
    //required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  _AdjustSplitScreenState createState() => _AdjustSplitScreenState();
}

class _AdjustSplitScreenState extends State<AdjustSplitScreen> {
  List<UserModel> memberList = [];
  List<String> selectedMemberIds = []; // UIDs of selected members
  List<UserModel> splitWithList = []; // List to hold users to split with
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'group' || widget.mode == 'group_face') {
      _fetchGroupAndMembers();
    } else if (widget.mode == "friend" || widget.mode == 'friend_face') {
      _fetchCurrentUser();
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
          currentUser =
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
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

  void _fetchGroupAndMembers() async {
    try {
      // Fetch the GroupModel using the groupName
      QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupName', isEqualTo: widget.name)
          .get();

      if (groupSnapshot.docs.isEmpty) {
        throw Exception('Group not found.');
      }

      // Convert the fetched group document to GroupModel
      GroupModel group = GroupModel.fromMap(
          groupSnapshot.docs.first.data() as Map<String, dynamic>);

      // Fetch the member details using their UIDs
      List<UserModel> members = [];
      for (String memberId in group.members) {
        DocumentSnapshot memberDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();
        if (memberDoc.exists) {
          members
              .add(UserModel.fromMap(memberDoc.data() as Map<String, dynamic>));
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

//   void _handleSelectionChanged(List<UserModel> updatedList) {
//   setState(() {
//     splitWithList = updatedList; // Update state
//   });
// }


  void _toggleSelection(UserModel member) {
    setState(() {
      if (selectedMemberIds.contains(member.uid)) {
        selectedMemberIds.remove(member.uid);
      } else {
        if (selectedMemberIds.length < 5) {
          selectedMemberIds.add(member.uid);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You can only select up to 5 members')),
          );
        }
      }
      // Update splitWithList based on current selection
      // splitWithList = memberList
      //     .where((member) => selectedMemberIds.contains(member.uid))
      //     .toList();
      // widget.onSelectionChanged(splitWithList);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'friend' || widget.mode == 'friend_face') {
      // Friend mode layout
      double amount = widget.amount ?? 0.0;
      double halfAmount = amount / 2;
      String friendName = widget.name ?? 'Friend';

      return Scaffold(
        appBar: AppBar(title: const Text('Choose Split Option')),
        body: ListView(
          children: [
            // Scenario: You paid, split equally
            ListTile(
              title: const Text(
                'You paid, split equally',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                '$friendName owes you \$${halfAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  if (currentUser != null) {
                    splitWithList.add(currentUser!);
                  } // Update splitWithList when currentUser is added
                });
                //widget.onSelectionChanged(splitWithList);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 5),
            // Scenario: You are owed the full amount
            ListTile(
              title: const Text(
                'You are owed the full amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                '$friendName owes you \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  if (currentUser != null) {
                    splitWithList.add(currentUser!);
                  } // Update splitWithList when currentUser is added
                });
               // widget.onSelectionChanged(splitWithList);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 5),
            // Scenario: Friend paid, split equally
            ListTile(
              title: Text(
                '$friendName paid, split equally',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'You owe $friendName \$${halfAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  UserModel friend = UserModel(
                    name: friendName,
                    uid: '',
                    username: '',
                    profilePic: '',
                    isAuthenticated: true,
                    friendsList: [],
                    email: '',
                  );
                  splitWithList.add(friend); // Add friend to splitWithList
                });
                //widget.onSelectionChanged(splitWithList);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 5),
            // Scenario: Friend is owed the full amount
            ListTile(
              title: Text(
                '$friendName is owed the whole amount',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'You owe $friendName \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  UserModel friend = UserModel(
                    name: friendName,
                    uid: '',
                    username: '',
                    profilePic: '',
                    isAuthenticated: true,
                    friendsList: [],
                    email: '',
                  );
                  splitWithList.add(friend); // Add friend to splitWithList
                });
                //widget.onSelectionChanged(splitWithList);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      // Group mode layout
      return Scaffold(
        appBar: AppBar(title: const Text('Adjust Split')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : memberList.isEmpty
                ? const Center(child: Text('No members found.'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: memberList.length,
                          itemBuilder: (context, index) {
                            UserModel member = memberList[index];
                            bool isSelected = selectedMemberIds.contains(member.uid);

                            return ListTile(
                              title: Text(member.name),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: isSelected ? Colors.green : null,
                              ),
                              onTap: () {
                                _toggleSelection(member);
                              },
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Notify the callback with the selected members' list
                         // widget.onSelectionChanged(splitWithList);
                          Navigator.pop(context);
                        },
                        child: const Text('Add Selected Members'),
                      ),
                    ],
                  ),
      );
    }
  }
}









// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:split_mate/models/group_model.dart';
// import 'package:split_mate/models/user_model.dart';

// class AdjustSplitScreen extends StatefulWidget {
//   final String? groupName; // Accepts the name of the group
//   final Function(List<UserModel>) onSelectionChanged; // Callback for selection change

//   const AdjustSplitScreen({required this.groupName, required this.onSelectionChanged, Key? key})
//       : super(key: key);

//   @override
//   _AdjustSplitScreenState createState() => _AdjustSplitScreenState();
// }

// class _AdjustSplitScreenState extends State<AdjustSplitScreen> {
//   List<UserModel> memberList = [];
//   List<UserModel> selectedMembers = [];
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
//           .where('groupName', isEqualTo: widget.groupName)
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

//   void _toggleSelection(UserModel member) {
//     setState(() {
//       if (selectedMembers.contains(member)) {
//         selectedMembers.remove(member);
//       } else {
//         if (selectedMembers.length < 5) {
//           selectedMembers.add(member);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('You can only select up to 5 members')),
//           );
//         }
//       }
//       widget.onSelectionChanged(selectedMembers);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Adjust Split')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : memberList.isEmpty
//               ? const Center(child: Text('No members found.'))
//               : ListView.builder(
//                   itemCount: memberList.length,
//                   itemBuilder: (context, index) {
//                     UserModel member = memberList[index];
//                     bool isSelected = selectedMembers.contains(member);

//                     return ListTile(
//                       title: Text(member.name),
//                       trailing: Icon(
//                         isSelected ? Icons.check_box : Icons.check_box_outline_blank,
//                         color: isSelected ? Colors.green : null,
//                       ),
//                       onTap: () => _toggleSelection(member),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// // void _toggleSelection(UserModel member) {
// //     setState(() {
// //       if (selectedMembers.contains(member)) {
// //         selectedMembers.remove(member);
// //       } else {
// //         if (selectedMembers.length < 5) {
// //           selectedMembers.add(member);
// //         } else {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('You can only select up to 5 members')),
// //           );
// //         }
// //       }
// //       widget.onSelectionChanged(selectedMembers);
// //     });
// //   }



